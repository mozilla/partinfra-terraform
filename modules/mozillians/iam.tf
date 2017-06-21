data "aws_iam_policy_document" "mozillians-bucket-policy" {
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
            "s3:PutObject"
        ]

        resources = [
            "${aws_s3_bucket.exports-bucket.arn}"
        ]
    }
}

# Note: This only creates the IAM policy, it needs to be attached to a user or role
resource "aws_iam_policy" "aws-access-policy" {
  name        = "mozillians-${var.environment}-s3-ses-es"
  path        = "/"
  description = "Mozillians ${var.environment} IAM policy for S3/SES/ES"
  policy = "${data.aws_iam_policy_document.mozillians-bucket-policy.json}"
}

output "aws-access-policy-arn" {
  value = "${aws_iam_policy.aws-access-policy.arn}"
}
