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

resource "aws_launch_configuration" "mozillians-slave-ec2-lc" {
  name_prefix                 = "mozillians-slave-production-lc"
  image_id                    = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type               = "t2.medium"
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
    elasticache_instance_size           = "cache.t2.micro"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
}

resource "aws_elasticsearch_domain" "mozillians-es" {
    domain_name                       = "mozillians-shared-es"
    elasticsearch_version             = "2.3"

    ebs_options {
        ebs_enabled                   = true
        volume_type                   = "standard"
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
