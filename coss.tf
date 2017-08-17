module "coss-production" {
    source                              = "./modules/coss"

    environment                         = "production"
}

module "coss-staging" {
    source                              = "./modules/coss"

    environment                         = "staging"
}
