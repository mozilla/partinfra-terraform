variable "iam-assume-role-policy" {}

data "aws_iam_policy_document" "policy-document" {
    statement {
        effect = "Allow"
        actions = [
            "es:*"
        ]

        resources = [
            "${var.elasticsearch_arn}",
            "${var.elasticsearch_arn}/*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "ses:SendRawEmail",
            "ses:GetSendQuota"
        ]

        resources = [
            "*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "s3:PutObject"
        ]

        resources = [
            "${aws_s3_bucket.exports-bucket.arn}/*"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "s3:PutObject",
            "s3:ListBucket"
        ]

        resources = [
            "${aws_s3_bucket.exports-bucket.arn}"
        ]
    }

    statement {
        effect = "Allow"
        actions = ["s3:*"]
        resources = [
            "arn:aws:s3:::mozillians-orgchart/*",
            "arn:aws:s3:::mozillians-orgchart"
        ]
    }

    statement {
        effect = "Allow"
        actions = [
            "sts:AssumeRole"
        ]

        resources = [
            "${var.cis_publisher_role_arn}"
        ]
    }
}

resource "aws_iam_role" "container-role" {
    name = "mozillians-${var.environment}-role"
    assume_role_policy = "${var.iam-assume-role-policy}"
}

resource "aws_iam_role_policy" "iam-role-policy" {
    name   = "mozillians-${var.environment}-role-policy"
    role   = "${aws_iam_role.container-role.name}"
    policy = "${data.aws_iam_policy_document.policy-document.json}"
}

output "aws-access-policy-arn" {
  value = "${aws_iam_role_policy.iam-role-policy.arn}"
}

output "container-role-arn" {
  value = "${aws_iam_role.container-role.arn}"
}
