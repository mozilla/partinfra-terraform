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
