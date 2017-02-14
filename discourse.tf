variable "discourse_api_key_production" {}
variable "discourse_api_key_staging" {}

module "discourse-production" {
    source                              = "./modules/discourse"

    environment                         = "production"
    vpc_id                              = "${aws_vpc.apps-production-vpc.id}"
    discourse_elasticache_instance_size = "cache.t2.medium"
    service_security_group_id           = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-production-subnet-group.name}"
    fqdn                                = "discourse.mozilla-community.org"
    ssl_certificate                     = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
    discourse_api_key                   = "${var.discourse_api_key_production}"
    lambda-functions-bucket             = "${aws_s3_bucket.lambda-functions.arn}"
}

module "discourse-staging" {
    source                              = "./modules/discourse"

    environment                         = "staging"
    vpc_id                              = "${aws_vpc.apps-staging-vpc.id}"
    discourse_elasticache_instance_size = "cache.t2.micro"
    service_security_group_id           = "${module.mesos-cluster-staging.mesos-cluster-slave-sg-id}"
    elasticache_subnet_group            = "${aws_elasticache_subnet_group.elasticache-staging-subnet-group.name}"
    fqdn                                = "discourse.staging.paas.mozilla.community"
    ssl_certificate                     = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
    discourse_api_key                   = "${var.discourse_api_key_staging}"
    lambda-functions-bucket             = "${aws_s3_bucket.lambda-functions.arn}"
}
