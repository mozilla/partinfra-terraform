variable "tf-sync-bucket" {}

provider "aws" {
  region = "${var.aws_region}"
}

provider "aws" {
  alias  = "us-west-1"
  region = "us-west-1"
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}

terraform {
    backend "s3" {
        bucket = "partinfra-tfsync"
        key    = "network/terraform.tfstate"
        region = "us-east-1"
    }
}

resource "aws_s3_bucket" "partinfra-tfsync" {
    bucket          = "${var.tf-sync-bucket}"
    acl             = "private"
    versioning {
        enabled     = true
    }
    tags {
        Name        = "${var.tf-sync-bucket}"
        Environment = "shared"
    }
}
