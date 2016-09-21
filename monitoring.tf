resource "aws_elasticache_subnet_group" "elasticache-shared-subnet-group" {
  name                 = "elasticache-shared-subnet-group"
  subnet_ids           = ["${aws_subnet.apps-shared-1a.id}", "${aws_subnet.apps-shared-1c.id}", "${aws_subnet.apps-shared-1d.id}"]
  description          = "Subnet group for shared VPC"
}

resource "aws_security_group" "sensu-redis-sg" {
  name                 = "sensu-redis-shared-sg"
  description          = "Sensu elasticache SG"
  vpc_id               = "${aws_vpc.apps-shared-vpc.id}"
}

resource "aws_security_group_rule" "sensu-redis-sg-allowredisfromall" {
  type                 = "ingress"
  from_port            = 6379
  to_port              = 6379
  protocol             = "tcp"
  cidr_blocks          = ["${aws_vpc.apps-production-vpc.cidr_block}", "${aws_vpc.apps-staging-vpc.cidr_block}", "${aws_vpc.apps-shared-vpc.cidr_block}"]

  security_group_id    = "${aws_security_group.sensu-redis-sg.id}"
}

resource "aws_security_group_rule" "sensu-redis-sg-allowegress" {
  type                 = "egress"
  from_port            = 0
  to_port              = 0
  protocol             = "-1"
  cidr_blocks          = ["${aws_vpc.apps-production-vpc.cidr_block}", "${aws_vpc.apps-staging-vpc.cidr_block}", "${aws_vpc.apps-shared-vpc.cidr_block}"]

  security_group_id    = "${aws_security_group.sensu-redis-sg.id}"
}

resource "aws_elasticache_cluster" "sensu-redis-ec" {
  cluster_id           = "sensu-redis-ec"
  engine               = "redis"
  engine_version       = "2.8.24"
  node_type            = "cache.t2.micro"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis2.8"
  subnet_group_name    = "${aws_elasticache_subnet_group.elasticache-shared-subnet-group.name}"
  security_group_ids   = ["${aws_security_group.sensu-redis-sg.id}"]
}
