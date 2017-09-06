module "coss-production" {
    source                              = "./modules/coss"

    environment                         = "production"
    iam-assume-role-policy              = "${data.aws_iam_policy_document.containers-assume-role-policy.json}"
}

module "coss-staging" {
    source                              = "./modules/coss"

    environment                         = "staging"
    iam-assume-role-policy              = "${data.aws_iam_policy_document.containers-assume-role-policy.json}"
}
