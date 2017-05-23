variable "adminaccessrole-uid" {}

data "aws_iam_policy_document" "marathon-backup-buckets-policy" {

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
            "${aws_s3_bucket.marathon-duplicity-backups.arn}",
            "${aws_s3_bucket.marathon-duplicity-backups.arn}/*"
        ]

        condition {
            test = "StringNotLike"
            variable = "aws:userId"
            values = [
                "${var.adminaccessrole-uid}:*",
                "${var.aws_account_id}"
            ]
        }
    }
}

resource "aws_s3_bucket" "marathon-duplicity-backups" {
    bucket = "marathon-${var.environment}-duplicity-backup"
    acl = "private"

    tags = {
        Name = "marathon-${var.environment}-duplicity-backup"
        app = "duplicity"
        project = "backup"
        env = "${var.environment}"
    }
}

resource "aws_s3_bucket_policy" "marathon-backup-buckets-policy-attachment" {
  bucket = "${aws_s3_bucket.marathon-duplicity-backups.id}"
  policy = "${data.aws_iam_policy_document.marathon-backup-buckets-policy.json}"
}
