module "discourse-production" {
    source                              = "./modules/discourse"

    environment                         = "production"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    discourse_elasticache_instance_size = "cache.t2.medium"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
    fqdn                                = "discourse.mozilla.org"
    ssl_certificate                     = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
    iam-assume-role-policy              = "${data.aws_iam_policy_document.containers-assume-role-policy.json}"
}

module "discourse-staging" {
    source                              = "./modules/discourse"

    environment                         = "staging"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    discourse_elasticache_instance_size = "cache.t2.micro"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
    fqdn                                = "discourse-staging.production.paas.mozilla.community"
    ssl_certificate                     = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
    iam-assume-role-policy              = "${data.aws_iam_policy_document.containers-assume-role-policy.json}"
}
