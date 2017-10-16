module "remo-staging" {
    source                              = "./modules/remo"

    environment                         = "staging"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    remo_elasticache_instance_size      = "cache.t2.micro"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
    elasticache_sg_name                 = "remo-redis-staging-sg"
    elasticache_sg_description          = "remo staging elasticache SG"
    iam-assume-role-policy              = "${data.aws_iam_policy_document.containers-assume-role-policy.json}"
}

module "remo-production" {
    source                              = "./modules/remo"

    environment                         = "production"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    remo_elasticache_instance_size      = "cache.t2.micro"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
    elasticache_sg_name                 = "remo-redis-shared-sg"
    elasticache_sg_description          = "remo elasticache SG"
    iam-assume-role-policy              = "${data.aws_iam_policy_document.containers-assume-role-policy.json}"
}

# Generic remo memcache instance
resource "aws_security_group" "remo-memcache-sg" {
    name = "generic-remo-memcache-sg"
    description = "Generic remo memcache SG"
    vpc_id = "${aws_vpc.apps-production-vpc.id}"
}

resource "aws_security_group_rule" "remo-memcache-sg-allowmemcachefromslaves" {
    type = "ingress"
    from_port = 11211
    to_port = 11211
    protocol = "tcp"
    source_security_group_id = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    security_group_id = "${aws_security_group.remo-memcache-sg.id}"
}

resource "aws_security_group_rule" "remo-memcache-sg-allowegress" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    security_group_id = "${aws_security_group.remo-memcache-sg.id}"
}

resource "aws_elasticache_cluster" "remo-memcache-ec" {
    cluster_id = "remo-generic"
    engine = "memcached"
    node_type = "cache.t2.micro"
    port = 11211
    num_cache_nodes = 1
    subnet_group_name = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
    security_group_ids = ["${aws_security_group.remo-memcache-sg.id}"]
    tags {
        Name = "remo-generic-memcache"
        app = "memcache"
        env = "production"
        project = "remo"
    }
}
