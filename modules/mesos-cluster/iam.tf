data "aws_iam_policy_document" "mesos-assume-role-policy" {

    statement {
        effect = "Allow"
        actions = [
            "sts:AssumeRole"
        ]

        principals {
            type = "Service"
            identifiers = [
                "ec2.amazonaws.com"
            ]
        }
    }
}

resource "aws_iam_role" "mesos-master-host-role" {
    name = "mesos-master-${var.environment}-host-role"
    assume_role_policy = "${data.aws_iam_policy_document.mesos-assume-role-policy.json}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role" "mesos-slave-host-role" {
    name = "mesos-slave-${var.environment}-host-role"
    assume_role_policy = "${data.aws_iam_policy_document.mesos-assume-role-policy.json}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role_policy_attachment" "mesos-master-host-mozdef-policy" {
    role = "${aws_iam_role.mesos-master-host-role.name}"
    policy_arn = "${lookup(var.unmanaged_role_arns, "mozdef-logging")}"
}

resource "aws_iam_instance_profile" "mesos-master-profile" {
    name = "mesos-master-${var.environment}-profile"
    roles = ["${aws_iam_role.mesos-master-host-role.name}"]
}

resource "aws_iam_instance_profile" "mesos-slave-profile" {
    name = "mesos-slave-${var.environment}-profile"
    roles = ["${aws_iam_role.mesos-slave-host-role.name}"]
}

output "slave-host-role-name" {
  value = "${aws_iam_role.mesos-slave-host-role.name}"
}
