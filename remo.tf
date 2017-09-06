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
