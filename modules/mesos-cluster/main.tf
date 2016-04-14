variable "environment" {}
variable "name" {}
variable "vpc_id" {}
variable "shared_vpc_cidr" {}
variable "master_instance_type" {}
variable "slave_instance_type" {}
variable "subnet1" {}
variable "subnet2" {}
variable "subnet3" {}

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
    ssl_certificate_id        = "arn:aws:iam::${var.aws_account_id}:server-certificate/wildcard-mozilla-community-ops-services"
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
    max_size                = 5
    desired_capacity        = 3
    min_size                = 3
    load_balancers          = ["${aws_elb.mesos-elb.id}"]
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
    max_size                = 5
    desired_capacity        = 3
    min_size                = 3
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
    lifecycle {
      create_before_destroy = true
    }
}
