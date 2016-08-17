variable "bitergia-db_password" {}

# VPC
resource "aws_vpc" "bitergia-metrics-vpc" {
    cidr_block              = "10.0.0.0/16"
    enable_dns_hostnames    = true
    enable_dns_support      = true
    instance_tenancy        = "default"

    tags {
        "Name"              = "bitergia-metrics-vpc"
        "app"               = "bitergia"
        "env"               = "production"
        "project"           = "metrics"
    }
}

resource "aws_subnet" "bitergia-metrics-public-subnet" {
    vpc_id                  = "${aws_vpc.bitergia-metrics-vpc.id}"
    cidr_block              = "10.0.0.0/17"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "bitergia-metrics-public-subnet"
        "app"               = "bitergia"
        "env"               = "production"
        "project"           = "metrics"
    }
}

resource "aws_subnet" "bitergia-metrics-private-subnet" {
    vpc_id                  = "${aws_vpc.bitergia-metrics-vpc.id}"
    cidr_block              = "10.0.128.0/17"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "bitergia-metrics-private-subnet"
        "app"               = "bitergia"
        "env"               = "production"
        "project"           = "metrics"
    }
}

resource "aws_internet_gateway" "bitergia-metrics-igw" {
  vpc_id                    = "${aws_vpc.bitergia-metrics-vpc.id}"
  tags {
    "Name"                  = "bitergia-metrics-igw"
    "app"                   = "bitergia"
    "env"                   = "production"
    "project"               = "metrics"
  }
}

resource "aws_route_table" "bitergia-metrics-rt" {
    vpc_id                  = "${aws_vpc.bitergia-metrics-vpc.id}"

    route {
        cidr_block          = "0.0.0.0/0"
        gateway_id          = "${aws_internet_gateway.bitergia-metrics-igw.id}"
    }

    tags {
        "Name"              = "bitergia-metrics-rt"
        "app"               = "bitergia"
        "env"               = "production"
        "project"           = "metrics"
    }
}

resource "aws_route_table_association" "bitergia-metrics-public-rtbassoc" {
    route_table_id = "${aws_route_table.bitergia-metrics-rt.id}"
    subnet_id      = "${aws_subnet.bitergia-metrics-public-subnet.id}"
}

# RDS
resource "aws_db_subnet_group" "bitergia-rds-subnetgroup" {
    name = "bitergia-rds-subnetgroup"
    description = "RDS subnet group for Bitergia"
    subnet_ids = ["${aws_subnet.bitergia-metrics-private-subnet.id}"]
    tags {
        "Name" = "bitergia-rds-subnetgroup"
        "app"               = "bitergia"
        "env"               = "production"
        "project"           = "metrics"
    }
}

resource "aws_security_group" "bitergia-rds-sg" {
    name        = "bitergia-rds-sg"
    description = "Bitergia RDS SG"
    vpc_id      = "${aws_vpc.bitergia-metrics-vpc.id}"
}

resource "aws_security_group_rule" "bitergia-rds-sg-allowrdsfromec2" {
    type              = "ingress"
    from_port         = 3306
    to_port           = 3306
    protocol          = "tcp"
    source_security_group_id = "${aws_security_group.bitergia-ec2-sg.id}"
    security_group_id = "${aws_security_group.bitergia-rds-sg.id}"
}

resource "aws_security_group_rule" "bitergia-ec2-sg-allowallfromvpc" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["${aws_vpc.bitergia-metrics-vpc.cidr_block}"]
    security_group_id = "${aws_security_group.bitergia-ec2-sg.id}"
}

resource "aws_db_instance" "bitergia-production-db" {
  allocated_storage    = 10
  engine               = "mariadb"
  engine_version       = "10.0.24"
  instance_class       = "db.t2.large"
  publicly_accessible  = false
  backup_retention_period = 7
  apply_immediately    = true
  multi_az             = false
  storage_type         = "gp2"
  final_snapshot_identifier = "bitergia-production-db-final"
  username             = "root"
  password             = "${var.bitergia-db_password}"
  vpc_security_group_ids = ["${aws_security_group.bitergia-rds-sg.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.bitergia-rds-subnetgroup.name}"
  parameter_group_name = "default.mariadb10.0"
  tags {
      Name                = "bitergia-production-db"
      app                 = "mysql"
      env                 = "production"
      project             = "metrics"
  }
}

# EC2
resource "aws_security_group" "bitergia-ec2-sg" {
    name                    = "bitergia-ec2-sg"
    description             = "Bitergia SG"
    vpc_id                  = "${aws_vpc.bitergia-metrics-vpc.id}"
}

resource "aws_security_group_rule" "bitergia-ec2-sg-allowallin" {
    type                    = "ingress"
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
    security_group_id       = "${aws_security_group.bitergia-ec2-sg.id}"
}

resource "aws_security_group_rule" "bitergia-ec2-sg-allowall" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.bitergia-ec2-sg.id}"
}

resource "aws_instance" "bitergia-ec2" {
    ami                     = "${lookup(var.aws_amis, "debian-jessie-8-4")}"
    instance_type           = "r3.large"
    disable_api_termination = false
    key_name                = "bitergia"
    vpc_security_group_ids  = ["${aws_security_group.bitergia-ec2-sg.id}"]
    subnet_id               = "${aws_subnet.bitergia-metrics-public-subnet.id}"

    root_block_device {
      volume_type = "standard"
      volume_size = 500
    }

    tags {
        Name                = "bitergia"
        app                 = "bitergia"
        env                 = "production"
        project             = "metrics"
    }
}
