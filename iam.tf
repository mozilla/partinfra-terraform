data "aws_iam_policy_document" "admin-access-assume-role-policy" {

    statement {
        effect = "Allow"
        actions = [
            "sts:AssumeRole",
        ]

        principals {
            type = "AWS"
            identifiers = [
                            "arn:aws:iam::${var.aws_account_id}:user/yalam96",
                            "arn:aws:iam::${var.aws_account_id}:user/nemo",
                            "arn:aws:iam::${var.aws_account_id}:user/akatsoulas"
                          ]
        }

        condition {
            test = "Bool"
            variable = "aws:MultiFactorAuthPresent"
            values = [
                "true",
            ]
        }
    }
}

resource "aws_iam_role" "admin-access-role" {
    name = "AdminAccessRole"
    assume_role_policy = "${data.aws_iam_policy_document.admin-access-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "admin-access-policy" {
    role = "${aws_iam_role.admin-access-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
