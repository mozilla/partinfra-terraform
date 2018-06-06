variable "environment" {}

resource "aws_s3_bucket" "discourse-backup" {
    bucket = "discourse-paas-${var.environment}-backup"
    acl = "private"

    lifecycle_rule {
        id = "data_retention"
        enabled = true
        expiration {
            days = 180
        }
    }

    tags {
        Name = "discourse-paas-${var.environment}-backup"
        app = "discourse"
        env = "${var.environment}"
        project = "discourse"
    }
}

data "aws_iam_policy_document" "discourse-backup-bucket-policy" {

    statement {
        effect = "Deny"
        actions = [
            "s3:*",
        ]

        principals {
            type = "AWS"
            identifiers = ["*"]
        }

        resources = [
            "${aws_s3_bucket.discourse-backup.arn}",
            "${aws_s3_bucket.discourse-backup.arn}/*",
        ]

        condition {
            test = "StringNotLike"
            variable = "aws:userId"
            values = [
                "${aws_iam_role.admin-access-role.unique_id}:*",
                "${lookup(var.unmanaged_role_ids, "admin-ec2-role")}:*",
                "${lookup(var.unmanaged_role_ids, "InfosecSecurityAuditRole")}:*",
                "${var.aws_account_id}"
            ]
        }
    }
}
