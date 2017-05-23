data "aws_iam_policy_document" "jenkins-backup-bucket-policy" {

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
            "${aws_s3_bucket.jenkins-duplicity-backup.arn}",
            "${aws_s3_bucket.jenkins-public-duplicity-backup.arn}",
            "${aws_s3_bucket.jenkins-duplicity-backup.arn}/*",
            "${aws_s3_bucket.jenkins-public-duplicity-backup.arn}/*"
        ]

        condition {
            test = "StringNotLike"
            variable = "aws:userId"
            values = [
                "${aws_iam_role.admin-access-role.unique_id}:*",
                "${var.terraform_role_id}:*",
                "${var.aws_account_id}"
            ]
        }
    }
}

resource "aws_s3_bucket" "jenkins-duplicity-backup" {
    bucket = "jenkins-duplicity-backup"
    acl = "private"

    tags = {
        Name = "jenkins-duplicity-backup"
        app = "duplicity"
        project = "backup"
    }
}

resource "aws_s3_bucket" "jenkins-public-duplicity-backup" {
    bucket = "jenkins-public-duplicity-backup"
    acl = "private"

    tags = {
        Name = "jenkins-public-duplicity-backup"
        app = "duplicity"
        project = "backup"
    }
}

resource "aws_s3_bucket_policy" "jenkins-backup-bucket-policy-attachment" {
  bucket = "${aws_s3_bucket.jenkins-duplicity-backup.id}"
  policy = "${data.aws_iam_policy_document.jenkins-backup-bucket-policy.json}"
}

resource "aws_s3_bucket_policy" "jenkins-public-backup-bucket-policy-attachment" {
  bucket = "${aws_s3_bucket.jenkins-public-duplicity-backup.id}"
  policy = "${data.aws_iam_policy_document.jenkins-backup-bucket-policy.json}"
}
