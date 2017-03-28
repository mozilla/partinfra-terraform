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

# Community Ops read-only group
resource "aws_iam_group" "community-ops" {
    name       = "Community-Ops"
    path       = "/"
}

data "aws_iam_policy_document" "community-ops-mfa-policy-document" {
    statement {
        effect  = "Allow"
        actions = [
            "iam:CreateVirtualMFADevice",
            "iam:EnableMFADevice",
        ]

        resources = [
            "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}",
        ]
    }
}

resource "aws_iam_group_policy" "community-ops-mfa-policy" {
    name   = "CommunityOpsMFA"
    group  = "${aws_iam_group.community-ops.id}"
    policy = "${data.aws_iam_policy_document.community-ops-mfa-policy-document.json}"
}

resource "aws_iam_group_policy_attachment" "community-ops-AmazonEC2ReadOnlyAccess" {
    group      = "${aws_iam_group.community-ops.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "community-ops-AmazonElastiCacheReadOnlyAccess" {
    group      = "${aws_iam_group.community-ops.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "community-ops-AmazonRoute53ReadOnlyAccess" {
    group      = "${aws_iam_group.community-ops.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "community-ops-AmazonVPCReadOnlyAccess" {
    group      = "${aws_iam_group.community-ops.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "community-ops-AutoScalingReadOnlyAccess" {
    group      = "${aws_iam_group.community-ops.name}"
    policy_arn = "arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "community-ops-CloudFrontReadOnlyAccess" {
    group      = "${aws_iam_group.community-ops.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudFrontReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "community-ops-CloudWatchReadOnlyAccess" {
    group      = "${aws_iam_group.community-ops.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# Community Ops elevated role
data "aws_iam_policy_document" "community-ops-assume-role-policy" {

    statement {
        effect          = "Allow"
        actions         = [
            "sts:AssumeRole",
        ]

        principals {
            type        = "AWS"
            identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
        }

        condition {
            test        = "Bool"
            variable    = "aws:MultiFactorAuthPresent"
            values      = [
                "true",
            ]
        }

        condition {
            test        = "StringEquals"
            variable    = "aws:PrincipalType"
            values      = [
                "User",
            ]
        }
    }
}

data "aws_iam_policy_document" "community-ops-elevated-policy" {
    statement {
        effect = "Allow"
        actions = [
            "iam:GenerateCredentialReport",
            "iam:GenerateServiceLastAccessedDetails",
            "iam:GetAccessKeyLastUsed",
            "iam:GetGroup",
            "iam:GetGroupPolicy",
            "iam:GetInstanceProfile",
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:GetUser",
            "iam:GetUserPolicy",
            "iam:ListAccessKeys",
            "iam:ListAttachedGroupPolicies",
            "iam:ListAttachedRolePolicies",
            "iam:ListAttachedUserPolicies",
            "iam:ListEntitiesForPolicy",
            "iam:ListGroupPolicies",
            "iam:ListGroups",
            "iam:ListGroupsForUser",
            "iam:ListMFADevices",
            "iam:ListPolicies",
            "iam:ListPolicyVersions",
            "iam:ListRolePolicies",
            "iam:ListRoles",
            "iam:ListUsers",
            "iam:ListVirtualMFADevices",
            "acm:AddTagsToCertificate",
            "acm:DescribeCertificate",
            "acm:GetCertificate",
            "acm:ListCertificates",
            "acm:ListTagsForCertificate",
            "acm:RemoveTagsFromCertificate",
            "acm:RequestCertificate",
            "acm:ResendValidationEmail",
            "route53:ChangeResourceRecordSets",
            "route53:ChangeTagsForResource",
            "route53:CreateHealthCheck",
            "route53:CreateHostedZone",
            "route53:CreateReusableDelegationSet",
            "route53:CreateTrafficPolicy",
            "route53:CreateTrafficPolicyInstance",
            "route53:CreateTrafficPolicyVersion",
            "route53:CreateVPCAssociationAuthorization",
            "route53:DeleteHealthCheck",
            "route53:DeleteReusableDelegationSet",
            "route53:DeleteTrafficPolicy",
            "route53:DeleteTrafficPolicyInstance",
            "route53:DisassociateVPCFromHostedZone",
            "route53:TestDNSAnswer",
            "route53:UpdateHealthCheck",
            "route53:UpdateHostedZoneComment",
            "route53:UpdateTrafficPolicyComment",
            "route53:UpdateTrafficPolicyInstance",
            "cloudfront:CreateInvalidation",
            "cloudfront:ListInvalidations"
        ]

        resources = [
            "*",
        ]
    }

    statement {
        effect    = "Deny"
        actions   = [
            "ec2:DescribeInstanceAttribute",
        ]

        resources = [
            "*",
        ]
    }

    statement {
        effect    = "Allow"
        actions   = [
            "iam:ChangePassword",
            "iam:CreateAccessKey",
            "iam:DeactivateMFADevice",
            "iam:DeleteAccessKey",
            "iam:DeleteVirtualMFADevice",
            "iam:ResyncMFADevice",
            "iam:UpdateAccessKey",
            "iam:UpdateUser",
        ]

        resources = [
            "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}",
        ]
    }

}

resource "aws_iam_role" "community-ops-elevated-role" {
    name               = "CommunityOpsElevated"
    assume_role_policy = "${data.aws_iam_policy_document.community-ops-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "community-ops-elevated-role-policy" {
    name   = "CommunityOpsElevated"
    role   = "${aws_iam_role.community-ops-elevated-role.name}"
    policy = "${data.aws_iam_policy_document.community-ops-elevated-policy.json}"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-role-AmazonS3ReadOnlyAccess" {
    role               = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn         = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-role-AmazonRDSReadOnlyAccess" {
    role               = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn         = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}
