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
        ]

        resources = [
            "arn:aws:iam::${var.aws_account_id}:mfa/$${aws:username}",
        ]
    }

    statement {
        effect  = "Allow"
        actions = [
            "iam:EnableMFADevice",
            "iam:GetUser",
            "iam:ListGroupsForUser",
            "iam:ListVirtualMFADevices",
        ]

        resources = [
            "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}",
        ]
    }

    statement {
        effect  = "Allow"
        actions = [
            "sts:AssumeRole",
        ]

        resources = [
            "${aws_iam_role.community-ops-elevated-role.arn}",
            "${aws_iam_role.community-ops-ro-role.arn}",
        ]
    }

    statement {
        effect  = "Allow"
        actions = [
            "iam:ListMFADevices",
            "iam:ListUsers",
        ]

        resources = [
            "arn:aws:iam::${var.aws_account_id}:user/",
            "arn:aws:iam::${var.aws_account_id}:mfa/",
        ]
    }
}

resource "aws_iam_group_policy" "community-ops-mfa-policy" {
    name   = "CommunityOpsMFA"
    group  = "${aws_iam_group.community-ops.id}"
    policy = "${data.aws_iam_policy_document.community-ops-mfa-policy-document.json}"
}

resource "aws_iam_role" "community-ops-ro-role" {
    name               = "CommunityOpsRO"
    assume_role_policy = "${data.aws_iam_policy_document.community-ops-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "community-ops-AmazonEC2ReadOnlyAccess" {
    role      = "${aws_iam_role.community-ops-ro-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-AmazonElastiCacheReadOnlyAccess" {
    role      = "${aws_iam_role.community-ops-ro-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-AmazonRoute53ReadOnlyAccess" {
    role      = "${aws_iam_role.community-ops-ro-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-AmazonVPCReadOnlyAccess" {
    role      = "${aws_iam_role.community-ops-ro-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-AutoScalingReadOnlyAccess" {
    role      = "${aws_iam_role.community-ops-ro-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-CloudFrontReadOnlyAccess" {
    role      = "${aws_iam_role.community-ops-ro-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudFrontReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-CloudWatchReadOnlyAccess" {
    role      = "${aws_iam_role.community-ops-ro-role.name}"
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
            "iam:GetUserPolicy",
            "iam:ListAccessKeys",
            "iam:ListAttachedGroupPolicies",
            "iam:ListAttachedRolePolicies",
            "iam:ListAttachedUserPolicies",
            "iam:ListEntitiesForPolicy",
            "iam:ListGroupPolicies",
            "iam:ListGroups",
            "iam:ListPolicies",
            "iam:ListPolicyVersions",
            "iam:ListRolePolicies",
            "iam:ListRoles",
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
            "cloudfront:ListInvalidations",
            "cloudwatch:PutMetricData"
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
            "iam:ResyncMFADevice",
            "iam:UpdateAccessKey",
            "iam:UpdateUser",
        ]

        resources = [
            "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}",
        ]
    }

    statement {
        effect    = "Allow"
        actions   = [
            "iam:DeactivateMFADevice",
        ]

        resources = [
            "arn:aws:iam::${var.aws_account_id}:mfa/$${aws:username}",
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

# Permissions aren't cascading, so we need to give the role the same permissions
resource "aws_iam_role_policy" "community-ops-elevated-mfa-policy" {
    name   = "CommunityOpsMFA"
    role   = "${aws_iam_role.community-ops-elevated-role.name}"
    policy = "${data.aws_iam_policy_document.community-ops-mfa-policy-document.json}"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-AmazonEC2ReadOnlyAccess" {
    role       = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-AmazonElastiCacheReadOnlyAccess" {
    role       = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-AmazonRoute53ReadOnlyAccess" {
    role       = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-AmazonVPCReadOnlyAccess" {
    role       = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-AutoScalingReadOnlyAccess" {
    role       = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-CloudFrontReadOnlyAccess" {
    role       = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudFrontReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "community-ops-elevated-CloudWatchReadOnlyAccess" {
    role       = "${aws_iam_role.community-ops-elevated-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
