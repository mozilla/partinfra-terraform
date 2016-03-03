# mesos-cluster staging
module "mesos-cluster-staging" {
    source = "./modules/mesos-cluster"
    # provider vars
    name = "mesos-cluster-staging"
    environment = "staging"
    vpc_id = "${aws_vpc.apps-staging-vpc.id}"
    shared_vpc_cidr = "${aws_vpc.apps-shared-vpc.cidr_block}"
}
module "mesos-cluster-production" {
    source = "./modules/mesos-cluster"
    # provider vars
    name = "mesos-cluster-production"
    environment = "production"
    vpc_id = "${aws_vpc.apps-production-vpc.id}"
    shared_vpc_cidr = "${aws_vpc.apps-shared-vpc.cidr_block}"
}
