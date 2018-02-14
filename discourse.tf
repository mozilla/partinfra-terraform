variable "discourse_production_tldr_api_key" {}
variable "discourse_staging_tldr_api_key" {}

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

module "discourse-production-tldr" {
    source                              = "./modules/discourse-tldr"

    environment                         = "production"
    discourse_tldr_api_key              = "${var.discourse_production_tldr_api_key}"
    discourse_tldr_api_username         = "tldr"
    discourse_tldr_category             = "253"
    discourse_tldr_url                  = "https://discourse.mozilla.org"
}

module "discourse-staging-tldr" {
    source                              = "./modules/discourse-tldr"

    environment                         = "staging"
    discourse_tldr_api_key              = "${var.discourse_staging_tldr_api_key}"
    discourse_tldr_api_username         = "tldr"
    discourse_tldr_category             = "216"
    discourse_tldr_url                  = "https://discourse-staging.production.paas.mozilla.community"
}
