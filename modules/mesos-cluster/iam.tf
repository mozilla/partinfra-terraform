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
    policy_arn = "arn:aws:iam::484535289196:policy/SnsMozdefLogsFullAccess"
}

resource "aws_iam_instance_profile" "mesos-master-profile" {
    name = "mesos-master-${var.environment}-profile"
    roles = ["${aws_iam_role.mesos-master-host-role.name}"]
}

resource "aws_iam_instance_profile" "mesos-slave-profile" {
    name = "mesos-slave-${var.environment}-profile"
    roles = ["${aws_iam_role.mesos-slave-host-role.name}"]
}

output "slave-host-role-arn" {
  value = "${aws_iam_role.mesos-slave-host-role.arn}"
}
