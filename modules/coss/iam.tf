data "aws_iam_policy_document" "coss-iam-policy" {
    statement {
        effect = "Allow"
        actions = [
            "s3:*"
        ]

        resources = [
            "${aws_s3_bucket.media-uploads.arn}",
            "${aws_s3_bucket.media-uploads.arn}/*"
        ]
    }
}

# Note: This only creates the IAM policy, it needs to be attached to a user or role
resource "aws_iam_policy" "aws-access-policy" {
  name        = "coss-${var.environment}-iam-policy"
  path        = "/"
  description = "Coss ${var.environment} IAM policy"
  policy = "${data.aws_iam_policy_document.coss-iam-policy.json}"
}
