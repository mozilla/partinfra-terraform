variable "bitergia-db_password" {}
variable "rust-metrics-es-iam-policy" {
    type    = "string"
    default = <<CONFIG
{
"Version": "2012-10-17",
"Statement": [
    {
        "Action": "es:*",
        "Principal": "*",
        "Effect": "Allow",
        "Condition": {
          "IpAddress": {
            "aws:SourceIp": [
              "13.57.24.109"
            ]
          }
        }
    }
]
}
CONFIG
}

# VPC
resource "aws_vpc" "bitergia-metrics-vpc" {
    provider                 = "aws.us-west-1"
    cidr_block               = "10.0.0.0/16"
    enable_dns_hostnames     = true
    enable_dns_support       = true
    instance_tenancy         = "default"

    tags {
        "Name"               = "bitergia-metrics-vpc"
        "app"                = "bitergia"
        "env"                = "production"
        "project"            = "metrics"
    }
}

resource "aws_subnet" "bitergia-metrics-public-subnet" {
    provider                 = "aws.us-west-1"
    vpc_id                   = "${aws_vpc.bitergia-metrics-vpc.id}"
    cidr_block               = "10.0.0.0/17"
    availability_zone        = "us-west-1a"
    map_public_ip_on_launch  = true

    tags {
        "Name"               = "bitergia-metrics-public-subnet"
        "app"                = "bitergia"
        "env"                = "production"
        "project"            = "metrics"
    }
}

resource "aws_subnet" "bitergia-metrics-private-subnet-1a" {
    provider                 = "aws.us-west-1"
    vpc_id                   = "${aws_vpc.bitergia-metrics-vpc.id}"
    cidr_block               = "10.0.128.0/18"
    availability_zone        = "us-west-1a"
    map_public_ip_on_launch  = true

    tags {
        "Name"               = "bitergia-metrics-private-subnet-1a"
        "app"                = "bitergia"
        "env"                = "production"
        "project"            = "metrics"
    }
}

resource "aws_subnet" "bitergia-metrics-private-subnet-1b" {
    provider                 = "aws.us-west-1"
    vpc_id                   = "${aws_vpc.bitergia-metrics-vpc.id}"
    cidr_block               = "10.0.192.0/18"
    availability_zone        = "us-west-1b"
    map_public_ip_on_launch  = true

    tags {
        "Name"               = "bitergia-metrics-private-subnet-1c"
        "app"                = "bitergia"
        "env"                = "production"
        "project"            = "metrics"
    }
}

resource "aws_internet_gateway" "bitergia-metrics-igw" {
  provider                   = "aws.us-west-1"
  vpc_id                     = "${aws_vpc.bitergia-metrics-vpc.id}"
  tags {
    "Name"                   = "bitergia-metrics-igw"
    "app"                    = "bitergia"
    "env"                    = "production"
    "project"                = "metrics"
  }
}

resource "aws_route_table" "bitergia-metrics-rt" {
    provider                 = "aws.us-west-1"
    vpc_id                   = "${aws_vpc.bitergia-metrics-vpc.id}"

    route {
        cidr_block           = "0.0.0.0/0"
        gateway_id           = "${aws_internet_gateway.bitergia-metrics-igw.id}"
    }

    tags {
        "Name"               = "bitergia-metrics-rt"
        "app"                = "bitergia"
        "env"                = "production"
        "project"            = "metrics"
    }
}

resource "aws_route_table_association" "bitergia-metrics-public-rtbassoc" {
    provider                 = "aws.us-west-1"
    route_table_id           = "${aws_route_table.bitergia-metrics-rt.id}"
    subnet_id                = "${aws_subnet.bitergia-metrics-public-subnet.id}"
}

# RDS
resource "aws_db_subnet_group" "bitergia-rds-subnetgroup" {
    provider                 = "aws.us-west-1"
    name                     = "bitergia-rds-subnetgroup"
    description              = "RDS subnet group for Bitergia"
    subnet_ids               = ["${aws_subnet.bitergia-metrics-private-subnet-1a.id}", "${aws_subnet.bitergia-metrics-private-subnet-1b.id}"]
    tags {
        "Name"               = "bitergia-rds-subnetgroup"
        "app"                = "bitergia"
        "env"                = "production"
        "project"            = "metrics"
    }
}

resource "aws_security_group" "bitergia-rds-sg" {
    provider                 = "aws.us-west-1"
    name                     = "bitergia-rds-sg"
    description              = "Bitergia RDS SG"
    vpc_id                   = "${aws_vpc.bitergia-metrics-vpc.id}"
}

resource "aws_security_group_rule" "bitergia-rds-sg-allowrdsfromec2" {
    provider                 = "aws.us-west-1"
    type                     = "ingress"
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.bitergia-ec2-sg.id}"
    security_group_id        = "${aws_security_group.bitergia-rds-sg.id}"
}

resource "aws_security_group_rule" "bitergia-ec2-sg-allowallfromvpc" {
    provider                 = "aws.us-west-1"
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks              = ["${aws_vpc.bitergia-metrics-vpc.cidr_block}"]
    security_group_id        = "${aws_security_group.bitergia-ec2-sg.id}"
}

resource "aws_db_instance" "bitergia-production-db" {
    provider                 = "aws.us-west-1"
  allocated_storage          = 10
  engine                     = "mariadb"
  engine_version             = "10.0.24"
  instance_class             = "db.t2.medium"
  publicly_accessible        = false
  backup_retention_period    = 7
  apply_immediately          = true
  multi_az                   = false
  storage_type               = "gp2"
  final_snapshot_identifier  = "bitergia-production-db-final"
  username                   = "root"
  password                   = "${var.bitergia-db_password}"
  vpc_security_group_ids     = ["${aws_security_group.bitergia-rds-sg.id}"]
  db_subnet_group_name       = "${aws_db_subnet_group.bitergia-rds-subnetgroup.name}"
  parameter_group_name       = "${aws_db_parameter_group.bitergia-production-params.id}"
  tags {
      Name                   = "bitergia-production-db"
      app                    = "mysql"
      env                    = "production"
      project                = "metrics"
  }
}

resource "aws_db_parameter_group" "bitergia-production-params" {
  provider = "aws.us-west-1"
  name   = "bitergia-mariadb10"
  family = "mariadb10.0"

  parameter {
    name  = "wait_timeout"
    value = "2592000"
  }

  parameter {
    name  = "interactive_timeout"
    value = "2592000"
  }
}


# EC2
resource "aws_security_group" "bitergia-ec2-sg" {
    provider                 = "aws.us-west-1"
    name                     = "bitergia-ec2-sg"
    description              = "Bitergia SG"
    vpc_id                   = "${aws_vpc.bitergia-metrics-vpc.id}"
}

resource "aws_security_group_rule" "bitergia-ec2-sg-allowallin" {
    provider                 = "aws.us-west-1"
    type                     = "ingress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks              = ["0.0.0.0/0"]
    security_group_id        = "${aws_security_group.bitergia-ec2-sg.id}"
}

resource "aws_security_group_rule" "bitergia-ec2-sg-allowall" {
    provider                 = "aws.us-west-1"
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks              = ["0.0.0.0/0"]

    security_group_id        = "${aws_security_group.bitergia-ec2-sg.id}"
}

resource "aws_instance" "bitergia-ec2-new" {
    provider                 = "aws.us-west-1"
    ami                      = "${lookup(var.aws_amis, "bitergia-2017-10-16")}"
    instance_type            = "r3.2xlarge"
    disable_api_termination  = false
    key_name                 = "bitergia"
    vpc_security_group_ids   = ["${aws_security_group.bitergia-ec2-sg.id}"]
    subnet_id                = "${aws_subnet.bitergia-metrics-public-subnet.id}"

    root_block_device {
      volume_type            = "gp2"
      volume_size            = 1000
    }

    tags {
        Name                 = "bitergia"
        app                  = "bitergia"
        env                  = "production"
        project              = "metrics"
    }
}

# ELB

resource "aws_security_group" "bitergia-elb-sg" {
  provider                    = "aws.us-west-1"
  name                        = "bitergia-production-elb-sg"
  description                 = "Bitergia ELB SG"
  vpc_id                      = "${aws_vpc.bitergia-metrics-vpc.id}"
}

resource "aws_security_group_rule" "bitergia-elb-sg-allowhttp" {
  provider                    = "aws.us-west-1"
  type                        = "ingress"
  from_port                   = 80
  to_port                     = 80
  protocol                    = "tcp"
  cidr_blocks                 = ["0.0.0.0/0"]
  security_group_id           = "${aws_security_group.bitergia-elb-sg.id}"
}

resource "aws_security_group_rule" "bitergia-elb-sg-allowhttps" {
  provider                    = "aws.us-west-1"
  type                        = "ingress"
  from_port                   = 443
  to_port                     = 443
  protocol                    = "tcp"
  cidr_blocks                 = ["0.0.0.0/0"]
  security_group_id           = "${aws_security_group.bitergia-elb-sg.id}"
}

resource "aws_security_group_rule" "bitergia-elb-sg-allowall" {
  provider                    = "aws.us-west-1"
  type                        = "egress"
  from_port                   = 0
  to_port                     = 0
  protocol                    = "-1"
  cidr_blocks                 = ["0.0.0.0/0"]
  security_group_id           = "${aws_security_group.bitergia-elb-sg.id}"
}

resource "aws_elb" "bitergia-elb" {
  provider                    = "aws.us-west-1"
  name                        = "bitergia-elb"
  security_groups             = ["${aws_security_group.bitergia-elb-sg.id}"]
  subnets                     = ["${aws_subnet.bitergia-metrics-public-subnet.id}"]
  instances                   = ["${aws_instance.bitergia-ec2-new.id}"]

  listener {
    instance_port             = 8080
    instance_protocol         = "http"
    lb_port                   = 80
    lb_protocol               = "http"
  }

  listener {
    instance_port             = 8080
    instance_protocol         = "http"
    lb_port                   = 443
    lb_protocol               = "https"
    ssl_certificate_id        = "${lookup(var.ssl_certificates, "analytics-us-west-1")}"
  }

  health_check {
    healthy_threshold         = 2
    unhealthy_threshold       = 2
    timeout                   = 3
    target                    = "TCP:80"
    interval                  = 30
  }

  cross_zone_load_balancing   = false
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name                      = "bitergia-elb"
    app                       = "bitergia"
    env                       = "production"
    project                   = "metrics"
  }
}

resource "aws_elasticsearch_domain" "bitergia-rust-metrics-es" {
    provider                          = "aws.us-west-1"
    domain_name                       = "bitergia-rust-metrics-es"
    elasticsearch_version             = "2.3"

    access_policies                   = "${var.rust-metrics-es-iam-policy}"

    ebs_options {
        ebs_enabled                   = true
        volume_type                   = "standard"
        volume_size                   = 50
    }

    cluster_config {
        instance_count                = 2
        instance_type                 = "m3.large.elasticsearch"
        dedicated_master_enabled      = false
        zone_awareness_enabled        = false
    }

    snapshot_options {
        automated_snapshot_start_hour = 23
    }

    tags {
      Domain                          = "bitergia-rust-metrics-es"
      app                             = "elasticsearch"
      env                             = "production"
      project                         = "metrics"
    }

    lifecycle {
      ignore_changes                    = ["access_policies"]
    }
}

resource "aws_elasticsearch_domain" "bitergia-metrics-es" {
    provider                          = "aws.us-west-1"
    domain_name                       = "bitergia-metrics-es"
    elasticsearch_version             = "5.1"

    access_policies                   = "${var.rust-metrics-es-iam-policy}"

    ebs_options {
        ebs_enabled                   = true
        volume_type                   = "gp2"
        volume_size                   = 300
    }

    cluster_config {
        instance_count                = 3
        instance_type                 = "m4.xlarge.elasticsearch"
        dedicated_master_enabled      = false
        zone_awareness_enabled        = false
    }

    snapshot_options {
        automated_snapshot_start_hour = 23
    }

    tags {
      Domain                          = "bitergia-metrics-es"
      app                             = "elasticsearch"
      env                             = "production"
      project                         = "metrics"
    }

    lifecycle {
      ignore_changes                    = ["access_policies"]
    }
}
