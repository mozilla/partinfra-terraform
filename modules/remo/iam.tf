variable "iam-assume-role-policy" {}

data "aws_iam_policy_document" "policy-document" {
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
    name = "remo-${var.environment}-role"
    assume_role_policy = "${var.iam-assume-role-policy}"
}

resource "aws_iam_role_policy" "iam-role-policy" {
    name   = "remo-${var.environment}-role-policy"
    role   = "${aws_iam_role.container-role.name}"
    policy = "${data.aws_iam_policy_document.policy-document.json}"
}

output "container-role-arn" {
  value = "${aws_iam_role.container-role.arn}"
}
