resource "aws_security_group" "mozillians-slave-ec2-sg" {
    name        = "mozillians-slave-production-ec2-sg"
    description = "mozillians slave production SG"
    vpc_id      = "${aws_vpc.apps-production-vpc.id}"
}

resource "aws_security_group_rule" "mozillians-slave-ec2-sg-allowallfrommaster" {
    type                     = "ingress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = "${module.mesos-cluster-production.mesos-cluster-master-sg-id}"

    security_group_id        = "${aws_security_group.mozillians-slave-ec2-sg.id}"
}

resource "aws_security_group_rule" "mozillians-slave-ec2-sg-allowall" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.mozillians-slave-ec2-sg.id}"
}

resource "aws_security_group_rule" "mozillians-slave-ec2-sg-allowallfromshared" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["${aws_vpc.apps-shared-vpc.cidr_block}"]

    security_group_id = "${aws_security_group.mozillians-slave-ec2-sg.id}"
}

data "aws_iam_policy_document" "mozillians-production-assume-role-policy" {

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

resource "aws_iam_role" "mozillians-production-role" {
    name = "mozillians-production-role"
    assume_role_policy = "${data.aws_iam_policy_document.mozillians-production-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "mozillians-production-mozdef-policy" {
    role = "${aws_iam_role.mozillians-production-role.name}"
    policy_arn = "arn:aws:iam::484535289196:policy/SnsMozdefLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "mozillians-production-access-policy" {
    role = "${aws_iam_role.mozillians-production-role.name}"
    policy_arn = "${module.mozillians-production.aws-access-policy-arn}"
}

resource "aws_iam_instance_profile" "mozillians-production-profile" {
    name = "mozillians-production-profile"
    roles = ["${aws_iam_role.mozillians-production-role.name}"]
}

resource "aws_launch_configuration" "mozillians-slave-ec2-lc" {
  name_prefix                 = "mozillians-slave-production-lc"
  image_id                    = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type               = "t2.medium"
  iam_instance_profile        = "${aws_iam_instance_profile.mozillians-production-profile.name}"
  key_name                    = "ansible"
  security_groups             = ["${aws_security_group.mozillians-slave-ec2-sg.id}"]
  associate_public_ip_address = true
  root_block_device {
    volume_size               = 20
  }
  lifecycle {
    create_before_destroy     = true
  }
}

resource "aws_autoscaling_group" "mozillians-slave-as" {
    name                    = "mozillians-slave-production-as"
    launch_configuration    = "${aws_launch_configuration.mozillians-slave-ec2-lc.id}"
    availability_zones      = ["${split(",", lookup(var.aws_availibility_zones, var.aws_region))}"]
    max_size                = "2"
    desired_capacity        = "2"
    min_size                = "2"
    vpc_zone_identifier     = ["${aws_subnet.apps-production-1a.id}", "${aws_subnet.apps-production-1c.id}", "${aws_subnet.apps-production-1d.id}"]
    tag {
      key                 = "Name"
      value               = "mesosslave"
      propagate_at_launch = true
    }
    tag {
      key                 = "app"
      value               = "mesosslaveproduction"
      propagate_at_launch = true
    }
    tag {
      key                 = "env"
      value               = "production"
      propagate_at_launch = true
    }
    tag {
      key                 = "project"
      value               = "mozillians"
      propagate_at_launch = true
    }
    tag {
      key                 = "cluster"
      value               = "mozillians"
      propagate_at_launch = true
    }
    lifecycle {
      create_before_destroy = true
    }
}

module "mozillians-staging" {
    source                              = "./modules/mozillians"

    environment                         = "staging"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    elasticache_redis_instance_size     = "cache.t2.micro"
    elasticache_memcached_instance_size = "cache.t2.micro"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
    elasticsearch_arn                   = "${aws_elasticsearch_domain.mozillians-es.arn}"
}

module "mozillians-production" {
    source                              = "./modules/mozillians"

    environment                         = "prod"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    elasticache_redis_instance_size     = "cache.t2.micro"
    elasticache_memcached_instance_size = "cache.t2.micro"
    service_security_group_id           = "${aws_security_group.mozillians-slave-ec2-sg.id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
    elasticsearch_arn                   = "${aws_elasticsearch_domain.mozillians-es.arn}"
}

resource "aws_elasticsearch_domain" "mozillians-es" {
    domain_name                       = "mozillians-shared-es"
    elasticsearch_version             = "2.3"

    ebs_options {
        ebs_enabled                   = true
        volume_type                   = "gp2"
        volume_size                   = 10
    }

    cluster_config {
        instance_count                = 3
        instance_type                 = "t2.micro.elasticsearch"
        dedicated_master_enabled      = false
        zone_awareness_enabled        = false
    }

    snapshot_options {
        automated_snapshot_start_hour = 23
    }
    tags {
      Domain                          = "mozillians-shared-es"
      app                             = "elasticsearch"
      env                             = "shared"
      project                         = "mozillians"
    }
}
