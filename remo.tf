module "remo-staging" {
    source                              = "./modules/remo"

    environment                         = "staging"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    remo_elasticache_instance_size      = "cache.t2.micro"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
}

module "remo-production" {
    source                              = "./modules/remo"

    environment                         = "production"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    remo_elasticache_instance_size      = "cache.t2.micro"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
}
