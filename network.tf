# VPC/Network setup for the entire infra
# create VPCs
resource "aws_vpc" "apps-production-vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name"           = "apps-production-vpc"
    }
}

resource "aws_vpc" "apps-staging-vpc" {
    cidr_block           = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name"           = "apps-staging-vpc"
    }
}

resource "aws_vpc" "apps-shared-vpc" {
    cidr_block           = "10.2.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name"           = "apps-shared-vpc"
    }
}


# create vpc peers

resource "aws_vpc_peering_connection" "apps-shared-to-production" {
    peer_owner_id = "${var.aws_account_id}"
    peer_vpc_id   = "${aws_vpc.apps-shared-vpc.id}"
    vpc_id        = "${aws_vpc.apps-production-vpc.id}"
    auto_accept   = true
}

resource "aws_vpc_peering_connection" "apps-shared-to-staging" {
    peer_owner_id = "${var.aws_account_id}"
    peer_vpc_id   = "${aws_vpc.apps-shared-vpc.id}"
    vpc_id        = "${aws_vpc.apps-staging-vpc.id}"
    auto_accept   = true
}

resource "aws_vpc_peering_connection" "apps-staging-to-production" {
    peer_owner_id = "${var.aws_account_id}"
    peer_vpc_id   = "${aws_vpc.apps-staging-vpc.id}"
    vpc_id        = "${aws_vpc.apps-production-vpc.id}"
    auto_accept   = true
}

# Create ACL rules to allow consul traffic between staging and prod but nothing else
resource "aws_network_acl_rule" "apps-staging-denyallproduction" {
    network_acl_id = "${aws_vpc.apps-staging-vpc.default_network_acl_id}"
    rule_number    = 90
    egress         = false
    protocol       = "all"
    rule_action    = "deny"
    cidr_block     = "${aws_vpc.apps-production-vpc.cidr_block}"
    from_port      = 0
    to_port        = 65535
}

resource "aws_network_acl_rule" "apps-production-denyallstaging" {
    network_acl_id = "${aws_vpc.apps-production-vpc.default_network_acl_id}"
    rule_number    = 90
    egress         = false
    protocol       = "all"
    rule_action    = "deny"
    cidr_block     = "${aws_vpc.apps-staging-vpc.cidr_block}"
    from_port      = 0
    to_port        = 65535
}

resource "aws_network_acl_rule" "apps-production-allowserftcpfromstaging" {
    network_acl_id = "${aws_vpc.apps-production-vpc.default_network_acl_id}"
    rule_number    = 30
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "${aws_vpc.apps-staging-vpc.cidr_block}"
    from_port      = 8300
    to_port        = 8302
}

resource "aws_network_acl_rule" "apps-production-allowserfudpfromstaging" {
    network_acl_id = "${aws_vpc.apps-production-vpc.default_network_acl_id}"
    rule_number    = 31
    egress         = false
    protocol       = "udp"
    rule_action    = "allow"
    cidr_block     = "${aws_vpc.apps-staging-vpc.cidr_block}"
    from_port      = 8300
    to_port        = 8302
}

resource "aws_network_acl_rule" "apps-staging-allowserftcpfromproduction" {
    network_acl_id = "${aws_vpc.apps-staging-vpc.default_network_acl_id}"
    rule_number    = 30
    egress         = false
    protocol       = "tcp"
    rule_action    = "allow"
    cidr_block     = "${aws_vpc.apps-production-vpc.cidr_block}"
    from_port      = 8300
    to_port        = 8302
}

resource "aws_network_acl_rule" "apps-staging-allowserfudpfromproduction" {
    network_acl_id = "${aws_vpc.apps-staging-vpc.default_network_acl_id}"
    rule_number    = 31
    egress         = false
    protocol       = "udp"
    rule_action    = "allow"
    cidr_block     = "${aws_vpc.apps-production-vpc.cidr_block}"
    from_port      = 8300
    to_port        = 8302
}
# Create Subnets

resource "aws_subnet" "apps-production-1a" {
    vpc_id                  = "${aws_vpc.apps-production-vpc.id}"
    cidr_block              = "10.0.0.0/18"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-production-1a"
    }
}

resource "aws_subnet" "apps-production-1c" {
    vpc_id                  = "${aws_vpc.apps-production-vpc.id}"
    cidr_block              = "10.0.64.0/18"
    availability_zone       = "us-east-1c"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-production-1c"
    }
}

resource "aws_subnet" "apps-production-1d" {
    vpc_id                  = "${aws_vpc.apps-production-vpc.id}"
    cidr_block              = "10.0.128.0/18"
    availability_zone       = "us-east-1d"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-production-1d"
    }
}




resource "aws_subnet" "apps-staging-1a" {
    vpc_id                  = "${aws_vpc.apps-staging-vpc.id}"
    cidr_block              = "10.1.0.0/18"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-staging-1a"
    }
}

resource "aws_subnet" "apps-staging-1c" {
    vpc_id                  = "${aws_vpc.apps-staging-vpc.id}"
    cidr_block              = "10.1.64.0/18"
    availability_zone       = "us-east-1c"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-staging-1c"
    }
}

resource "aws_subnet" "apps-staging-1d" {
    vpc_id                  = "${aws_vpc.apps-staging-vpc.id}"
    cidr_block              = "10.1.128.0/18"
    availability_zone       = "us-east-1d"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-staging-1d"
    }
}



resource "aws_subnet" "apps-shared-1a" {
    vpc_id                  = "${aws_vpc.apps-shared-vpc.id}"
    cidr_block              = "10.2.0.0/18"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-shared-1a"
    }
}

resource "aws_subnet" "apps-shared-1c" {
    vpc_id                  = "${aws_vpc.apps-shared-vpc.id}"
    cidr_block              = "10.2.64.0/18"
    availability_zone       = "us-east-1c"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-shared-1c"
    }
}

resource "aws_subnet" "apps-shared-1d" {
    vpc_id                  = "${aws_vpc.apps-shared-vpc.id}"
    cidr_block              = "10.2.128.0/18"
    availability_zone       = "us-east-1d"
    map_public_ip_on_launch = true

    tags {
        "Name"              = "apps-shared-1d"
    }
}

# Create internet gateways
resource "aws_internet_gateway" "apps-production-igw" {
  vpc_id = "${aws_vpc.apps-production-vpc.id}"
  tags   = {
    Name = "apps-production-igw"
  }
}

resource "aws_internet_gateway" "apps-staging-igw" {
  vpc_id = "${aws_vpc.apps-staging-vpc.id}"
  tags   = {
    Name = "apps-staging-igw"
  }
}

resource "aws_internet_gateway" "apps-shared-igw" {
  vpc_id = "${aws_vpc.apps-shared-vpc.id}"
  tags   = {
    Name = "apps-shared-igw"
  }
}


# Set up route tables and associate them with the subnets

resource "aws_route_table" "apps-production-rt" {
    vpc_id                        = "${aws_vpc.apps-production-vpc.id}"

    route {
        cidr_block                = "${aws_vpc.apps-shared-vpc.cidr_block}"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.apps-shared-to-production.id}"
    }

    route {
        cidr_block                = "${aws_vpc.apps-staging-vpc.cidr_block}"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.apps-staging-to-production.id}"
    }

    route {
        cidr_block                = "0.0.0.0/0"
        gateway_id                = "${aws_internet_gateway.apps-production-igw.id}"
    }

    tags {
        "Name"                    = "apps-production-rt"
    }
}

resource "aws_route_table" "apps-staging-rt" {
    vpc_id                        = "${aws_vpc.apps-staging-vpc.id}"

    route {
        cidr_block                = "${aws_vpc.apps-shared-vpc.cidr_block}"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.apps-shared-to-staging.id}"
    }

    route {
        cidr_block                = "${aws_vpc.apps-production-vpc.cidr_block}"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.apps-staging-to-production.id}"
    }

    route {
        cidr_block                = "0.0.0.0/0"
        gateway_id                = "${aws_internet_gateway.apps-staging-igw.id}"
    }

    tags {
        "Name"                    = "apps-staging-rt"
    }
}

resource "aws_route_table" "apps-shared-rt" {
    vpc_id                        = "${aws_vpc.apps-shared-vpc.id}"

    route {
        cidr_block                = "${aws_vpc.apps-production-vpc.cidr_block}"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.apps-shared-to-production.id}"
    }

    route {
        cidr_block                = "${aws_vpc.apps-staging-vpc.cidr_block}"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.apps-shared-to-staging.id}"
    }

    route {
        cidr_block                = "0.0.0.0/0"
        gateway_id                = "${aws_internet_gateway.apps-shared-igw.id}"
    }

    tags {
        "Name"                    = "apps-shared-rt"
    }
}

resource "aws_route_table_association" "apps-production-1a-rtbassoc" {
    route_table_id = "${aws_route_table.apps-production-rt.id}"
    subnet_id      = "${aws_subnet.apps-production-1a.id}"
}

resource "aws_route_table_association" "apps-production-1c-rtbassoc" {
    route_table_id = "${aws_route_table.apps-production-rt.id}"
    subnet_id      = "${aws_subnet.apps-production-1c.id}"
}

resource "aws_route_table_association" "apps-production-1d-rtbassoc" {
    route_table_id = "${aws_route_table.apps-production-rt.id}"
    subnet_id      = "${aws_subnet.apps-production-1d.id}"
}



resource "aws_route_table_association" "apps-staging-1a-rtbassoc" {
    route_table_id = "${aws_route_table.apps-staging-rt.id}"
    subnet_id      = "${aws_subnet.apps-staging-1a.id}"
}

resource "aws_route_table_association" "apps-staging-1c-rtbassoc" {
    route_table_id = "${aws_route_table.apps-staging-rt.id}"
    subnet_id      = "${aws_subnet.apps-staging-1c.id}"
}

resource "aws_route_table_association" "apps-staging-1d-rtbassoc" {
    route_table_id = "${aws_route_table.apps-staging-rt.id}"
    subnet_id      = "${aws_subnet.apps-staging-1d.id}"
}



resource "aws_route_table_association" "apps-shared-1a-rtbassoc" {
    route_table_id = "${aws_route_table.apps-shared-rt.id}"
    subnet_id      = "${aws_subnet.apps-shared-1a.id}"
}

resource "aws_route_table_association" "apps-shared-1c-rtbassoc" {
    route_table_id = "${aws_route_table.apps-shared-rt.id}"
    subnet_id      = "${aws_subnet.apps-shared-1c.id}"
}

resource "aws_route_table_association" "apps-shared-1d-rtbassoc" {
    route_table_id = "${aws_route_table.apps-shared-rt.id}"
    subnet_id      = "${aws_subnet.apps-shared-1d.id}"
}
