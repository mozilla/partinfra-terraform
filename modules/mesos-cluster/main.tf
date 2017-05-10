variable "environment" {}
variable "name" {}
variable "vpc_id" {}
variable "shared_vpc_cidr" {}
variable "master_instance_type" {}
variable "slave_instance_type" {}
variable "subnet1" {}
variable "subnet2" {}
variable "subnet3" {}
variable "sns_topic_arn" {}
variable "slave_as_max_size" {}
variable "slave_as_desired_capacity" {}
variable "slave_as_min_size" {}
variable "master_as_max_size" {}
variable "master_as_desired_capacity" {}
variable "master_as_min_size" {}


data "aws_iam_policy_document" "mesos-assume-role-policy" {

    statement {
        effect = "Allow"
        actions = [
            "sts:AssumeRole",
        ]

        principals {
            type = "Service"
            identifiers = [
                "ec2.amazonaws.com"
            ]
        }
    }
}

resource "aws_iam_role" "mesos-role" {
    name = "mesos-${var.environment}-role"
    assume_role_policy = "${data.aws_iam_policy_document.mesos-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "mesos-access-policy" {
    role = "${aws_iam_role.mesos-role.name}"
    policy_arn = "arn:aws:iam::484535289196:policy/SnsMozdefLogsFullAccess"
}

resource "aws_iam_instance_profile" "mesos-profile" {
    name = "mesos-${var.environment}-profile"
    roles = ["${aws_iam_role.mesos-role.name}"]
}

resource "aws_elb" "mesos-elb" {
  name                        = "mesos-${var.environment}-elb"
  security_groups             = ["${aws_security_group.mesos-elb-sg.id}"]
  subnets                     = ["${var.subnet1}", "${var.subnet2}", "${var.subnet3}"]
  listener {
    instance_port             = 80
    instance_protocol         = "http"
    lb_port                   = 80
    lb_protocol               = "http"
  }

  listener {
    instance_port             = 80
    instance_protocol         = "http"
    lb_port                   = 443
    lb_protocol               = "https"
    ssl_certificate_id        = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
  }

  health_check {
    healthy_threshold         = 2
    unhealthy_threshold       = 2
    timeout                   = 3
    target                    = "TCP:80"
    interval                  = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name                      = "mesos-${var.environment}-elb"
    app                       = "mesos-cluster"
    env                       = "${var.environment}"
  }
}

resource "aws_route53_record" "paas-default-dns-zone" {
  zone_id =  "${var.paas-mozilla-community-zone-id}"
  name = "*.${var.environment}"
  type = "CNAME"
  ttl = 300
  records = ["${aws_elb.mesos-elb.dns_name}"]
}

resource "aws_launch_configuration" "mesos-master-ec2-lc" {
  name_prefix                 = "mesos-master-${var.environment}-lc-"
  image_id                    = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type               = "${var.master_instance_type}"
  key_name                    = "ansible"
  security_groups             = ["${aws_security_group.mesos-master-ec2-sg.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.mesos-profile.name}"
  associate_public_ip_address = true
  root_block_device {
    volume_size               = 100
  }
  lifecycle {
    create_before_destroy     = true
  }
}

resource "aws_launch_configuration" "mesos-slave-ec2-lc" {
  name_prefix                 = "mesos-slave-${var.environment}-lc-"
  image_id                    = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type               = "${var.slave_instance_type}"
  key_name                    = "ansible"
  security_groups             = ["${aws_security_group.mesos-slave-ec2-sg.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.mesos-profile.name}"
  associate_public_ip_address = true
  root_block_device {
    volume_size               = 100
  }
  lifecycle {
    create_before_destroy     = true
  }
}

resource "aws_autoscaling_group" "mesos-master-as" {
    name                    = "mesos-master-${var.environment}-as"
    launch_configuration    = "${aws_launch_configuration.mesos-master-ec2-lc.id}"
    availability_zones      = ["${split(",", lookup(var.aws_availibility_zones, var.aws_region))}"]
    max_size                = "${var.master_as_max_size}"
    desired_capacity        = "${var.master_as_desired_capacity}"
    min_size                = "${var.master_as_min_size}"
    load_balancers          = ["${aws_elb.mesos-elb.id}", "${aws_elb.community-sites-elb.id}", "${aws_elb.mozilla-org-elb.id}"]
    vpc_zone_identifier     = ["${var.subnet1}", "${var.subnet2}", "${var.subnet3}"]
    tag {
      key                   = "app"
      value                 = "mesosmaster${var.environment}"
      propagate_at_launch   = true
    }

    tag {
      key                   = "env"
      value                 = "${var.environment}"
      propagate_at_launch   = true
    }
    tag {
      key                   = "Name"
      value                 = "mesosmaster"
      propagate_at_launch   = true
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "mesos-slave-as" {
    name                    = "mesos-slave-${var.environment}-as"
    launch_configuration    = "${aws_launch_configuration.mesos-slave-ec2-lc.id}"
    availability_zones      = ["${split(",", lookup(var.aws_availibility_zones, var.aws_region))}"]
    max_size                = "${var.slave_as_max_size}"
    desired_capacity        = "${var.slave_as_desired_capacity}"
    min_size                = "${var.slave_as_min_size}"
    vpc_zone_identifier     = ["${var.subnet1}", "${var.subnet2}", "${var.subnet3}"]
    tag {
      key                   = "app"
      value                 = "mesosslave${var.environment}"
      propagate_at_launch   = true
    }

    tag {
      key                   = "env"
      value                 = "${var.environment}"
      propagate_at_launch   = true
    }
    tag {
      key                   = "Name"
      value                 = "mesosslave"
      propagate_at_launch   = true
    }
    tag {
      key                   = "cluster"
      value                 = "generic"
      propagate_at_launch   = true
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_elb" "community-sites-elb" {
  name                        = "community-sites-${var.environment}-elb"
  security_groups             = ["${aws_security_group.mesos-elb-sg.id}"]
  subnets                     = ["${var.subnet1}", "${var.subnet2}", "${var.subnet3}"]
  listener {
    instance_port             = 80
    instance_protocol         = "http"
    lb_port                   = 80
    lb_protocol               = "http"
  }

  listener {
    instance_port             = 80
    instance_protocol         = "http"
    lb_port                   = 443
    lb_protocol               = "https"
    ssl_certificate_id        = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
  }

  health_check {
    healthy_threshold         = 2
    unhealthy_threshold       = 2
    timeout                   = 3
    target                    = "TCP:80"
    interval                  = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name                      = "community-sites-elb"
    app                       = "mesos-cluster"
    env                       = "${var.environment}"
  }
}

  resource "aws_elb" "mozilla-org-elb" {
    name                        = "mozilla-org-${var.environment}-elb"
    security_groups             = ["${aws_security_group.mesos-elb-sg.id}"]
    subnets                     = ["${var.subnet1}", "${var.subnet2}", "${var.subnet3}"]
    listener {
      instance_port             = 80
      instance_protocol         = "http"
      lb_port                   = 80
      lb_protocol               = "http"
    }

    listener {
      instance_port             = 80
      instance_protocol         = "http"
      lb_port                   = 443
      lb_protocol               = "https"
      ssl_certificate_id        = "${lookup(var.ssl_certificates, "mozilla-org-elb-${var.aws_region}")}"
    }

    health_check {
      healthy_threshold         = 2
      unhealthy_threshold       = 2
      timeout                   = 3
      target                    = "TCP:80"
      interval                  = 30
    }

    cross_zone_load_balancing   = true
    idle_timeout                = 400
    connection_draining         = true
    connection_draining_timeout = 400

    tags {
      Name                      = "mozilla-org-elb"
      app                       = "mesos-cluster"
      env                       = "${var.environment}"
    }
  }

resource "aws_route53_record" "paas-mozilla-org-dns-zone" {
  zone_id =  "${var.paas-mozilla-community-zone-id}"
  name = "*.${var.environment}-mozorg"
  type = "CNAME"
  ttl = 300
  records = ["${aws_elb.mozilla-org-elb.dns_name}"]
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch-health-host-count-elb-alarm" {
  alarm_name = "cloudwatch-health-count-${var.environment}"
  comparison_operator = "LessThanThreshold"
  metric_name = "HealthyHostCount"
  threshold = "${var.master_as_desired_capacity}"
  statistic = "Average"
  period = "120"
  alarm_description = "Monitor number of healthy instances."
  ok_actions = []
  insufficient_data_actions = []
  namespace = "AWS/ELB"
  dimensions = {
    "LoadBalancerName"="mesos-${var.environment}-elb"
  }
  actions_enabled = true
  alarm_actions = ["${var.sns_topic_arn}"]
  evaluation_periods = "2"
}
