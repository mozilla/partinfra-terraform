variable "vpc_id" {}
variable "discourse_elasticache_instance_size" {}
variable "elasticache_subnet_group" {}
variable "service_security_group_id" {}
variable "environment" {}
variable "fqdn" {}
variable "ssl_certificate" {}
variable "aws_account_id" {}
variable "InfosecSecurityAuditRole_uid" {}

resource "aws_security_group" "discourse-redis-sg" {
    name                     = "discourse-redis-shared-sg"
    description              = "discourse elasticache SG"
    vpc_id                   = "${var.vpc_id}"
}

resource "aws_security_group_rule" "discourse-redis-sg-allowredisfromslaves" {
    type                     = "ingress"
    from_port                = 6379
    to_port                  = 6379
    protocol                 = "tcp"
    source_security_group_id = "${var.service_security_group_id}"
    security_group_id        = "${aws_security_group.discourse-redis-sg.id}"
}

resource "aws_security_group_rule" "discourse-redis-sg-allowegress" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = "${var.service_security_group_id}"
    security_group_id        = "${aws_security_group.discourse-redis-sg.id}"
}

resource "aws_elasticache_cluster" "discourse-redis-ec" {
    cluster_id                 = "discourse-${var.environment}"
    engine                     = "redis"
    engine_version             = "2.8.24"
    node_type                  = "${var.discourse_elasticache_instance_size}"
    port                       = 6379
    num_cache_nodes            = 1
    parameter_group_name       = "default.redis2.8"
    subnet_group_name          = "${var.elasticache_subnet_group}"
    security_group_ids         = ["${aws_security_group.discourse-redis-sg.id}"]
    tags {
        Name                   = "discourse-${var.environment}-redis"
        app                    = "redis"
        env                    = "${var.environment}"
        project                = "discourse"
    }
}

resource "aws_s3_bucket" "discourse-content" {
    bucket = "discourse-paas-${var.environment}-content"
    acl = "private"

    lifecycle_rule {
        id = "purge-tombstone"
        prefix = "tombstone/"
        enabled = true
        expiration {
            days = 30
        }
    }

    tags {
        Name = "discourse-paas-${var.environment}-content"
        app = "discourse"
        env = "${var.environment}"
        project = "discourse"
    }
}

data "aws_iam_policy_document" "discourse-content-policy" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    principals = {
        type = "AWS"
        identifiers = [
            "arn:aws:iam::${var.aws_account_id}:user/discourse-${var.environment}-ses-s3",
        ]
    }
    resources = [
      "${aws_s3_bucket.discourse-content.arn}",
      "${aws_s3_bucket.discourse-content.arn}/*",
    ]
  }

  statement {
    effect = "Deny"
    actions = [
      "s3:*",
    ]

    principals {
        type = "AWS"
        identifiers = ["*"]
    }

    condition {
        test = "StringNotLike"
        variable = "aws:userId"
        values = [
            "${var.InfosecSecurityAuditRole_uid}:*",
            "${var.aws_account_id}"
        ]
    }

    resources = [
      "${aws_s3_bucket.discourse-content.arn}",
      "${aws_s3_bucket.discourse-content.arn}/*",
    ]
  }
}


resource "aws_s3_bucket_policy" "discourse-content-policy-attachment" {
  bucket = "${aws_s3_bucket.discourse-content.id}"
  policy = "${data.aws_iam_policy_document.discourse-content-policy.json}"
}

module "discourse-cdn" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "${var.fqdn}"
  origin_path         = ""
  origin_id           = "discourse-pull-origin"
  compression         = true
  alias               = "cdn-${var.environment}.discourse.mozilla-community.org"
  comment             = "Discourse ${var.environment} CDN"
  acm_certificate_arn = "${var.ssl_certificate}"
}
