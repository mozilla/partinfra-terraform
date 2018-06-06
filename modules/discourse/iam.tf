variable "iam-assume-role-policy" {}

data "aws_iam_policy_document" "policy-document" {
    statement {
        effect  = "Allow"
        actions = [
            "s3:*",
        ]

        resources = [
            "${aws_s3_bucket.discourse-content.arn}",
        ]
    }

    statement {
        effect  = "Allow"
        actions = [
            "s3:*",
        ]

        resources = [
            "${aws_s3_bucket.discourse-content.arn}/*",
        ]
    }

    statement {
        effect  = "Allow"
        actions = [
            "s3:PutObject",
        ]

        resources = [
            "${aws_s3_bucket.discourse-backup.arn}",
            "${aws_s3_bucket.discourse-backup.arn}/*",
        ]
    }

    statement {
        effect  = "Allow"
        actions = [
            "ses:SendRawEmail",
        ]

        resources = [
            "*",
        ]
    }
}

resource "aws_iam_role" "container-role" {
    name = "discourse-${var.environment}-role"
    assume_role_policy = "${var.iam-assume-role-policy}"
}

resource "aws_iam_role_policy" "iam-role-policy" {
    name   = "discourse-${var.environment}-role-policy"
    role   = "${aws_iam_role.container-role.name}"
    policy = "${data.aws_iam_policy_document.policy-document.json}"
}

output "container-role-arn" {
  value = "${aws_iam_role.container-role.arn}"
}
