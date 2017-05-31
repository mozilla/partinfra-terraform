# mesos-cluster staging
module "mesos-cluster-staging" {
    source               = "./modules/mesos-cluster"
    # provider vars
    name                 = "mesos-cluster-staging"
    environment          = "staging"
    master_instance_type = "t2.micro"
    slave_instance_type  = "t2.medium"
    slave_as_max_size   = 1
    slave_as_desired_capacity = 1
    slave_as_min_size   = 1
    master_as_max_size   = 1
    master_as_desired_capacity = 1
    master_as_min_size   = 1

    vpc_id               = "${aws_vpc.apps-staging-vpc.id}"
    shared_vpc_cidr      = "${aws_vpc.apps-shared-vpc.cidr_block}"
    # We can't interpolate referenced resources so we have to manually add subnets
    subnet1              = "${aws_subnet.apps-staging-1a.id}"
    subnet2              = "${aws_subnet.apps-staging-1c.id}"
    subnet3              = "${aws_subnet.apps-staging-1d.id}"
    sns_topic_arn        = "${aws_sns_topic.sns-cloudwatch-partinfra.arn}"
    aws_account_id       = "${var.aws_account_id}"
    adminaccessrole-uid  = "${aws_iam_role.admin-access-role.unique_id}"
}

module "mesos-cluster-production" {
    source               = "./modules/mesos-cluster"
    # provider vars
    name                 = "mesos-cluster-production"
    environment          = "production"
    master_instance_type = "t2.micro"
    slave_instance_type  = "t2.medium"
    slave_as_max_size   = 5
    slave_as_desired_capacity = 5
    slave_as_min_size   = 5
    master_as_max_size   = 5
    master_as_desired_capacity = 3
    master_as_min_size   = 3

    vpc_id               = "${aws_vpc.apps-production-vpc.id}"
    shared_vpc_cidr      = "${aws_vpc.apps-shared-vpc.cidr_block}"
    # We can't interpolate referenced resources so we have to manually add subnets
    subnet1              = "${aws_subnet.apps-production-1a.id}"
    subnet2              = "${aws_subnet.apps-production-1c.id}"
    subnet3              = "${aws_subnet.apps-production-1d.id}"
    sns_topic_arn        = "${aws_sns_topic.sns-cloudwatch-partinfra.arn}"
    aws_account_id       = "${var.aws_account_id}"
    adminaccessrole-uid  = "${aws_iam_role.admin-access-role.unique_id}"
}
