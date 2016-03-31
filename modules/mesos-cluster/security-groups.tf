resource "aws_security_group" "mesos-elb-sg" {
    name        = "mesos-elb-${var.environment}-sg"
    description = "Mesos ${var.environment} ELB SG"
    vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "mesos-elb-sg-allowhttp" {
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.mesos-elb-sg.id}"
}
resource "aws_security_group_rule" "mesos-elb-sg-allowhttps" {
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.mesos-elb-sg.id}"
}
resource "aws_security_group_rule" "mesos-elb-sg-allowall" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.mesos-elb-sg.id}"
}
resource "aws_security_group" "mesos-master-ec2-sg" {
    name        = "mesos-master-${var.environment}-ec2-sg"
    description = "Mesos master ${var.environment} SG"
    vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "mesos-master-ec2-sg-allowhttpfromelb" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.mesos-elb-sg.id}"

    security_group_id        = "${aws_security_group.mesos-master-ec2-sg.id}"
}
resource "aws_security_group_rule" "mesos-master-ec2-sg-allowhttpsfromelb" {
    type                     = "ingress"
    from_port                = 443
    to_port                  = 443
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.mesos-elb-sg.id}"

    security_group_id        = "${aws_security_group.mesos-master-ec2-sg.id}"
}
resource "aws_security_group_rule" "mesos-master-ec2-sg-allowallfromself" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    self              = true

    security_group_id = "${aws_security_group.mesos-master-ec2-sg.id}"
}
resource "aws_security_group_rule" "mesos-master-ec2-sg-allowallfromslave" {
    type                     = "ingress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = "${aws_security_group.mesos-slave-ec2-sg.id}"

    security_group_id        = "${aws_security_group.mesos-master-ec2-sg.id}"
}
resource "aws_security_group_rule" "mesos-master-ec2-sg-allowall" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.mesos-master-ec2-sg.id}"
}
resource "aws_security_group_rule" "mesos-master-ec2-sg-allowallfromshared" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["${var.shared_vpc_cidr}"]

    security_group_id = "${aws_security_group.mesos-master-ec2-sg.id}"
}
resource "aws_security_group" "mesos-slave-ec2-sg" {
    name        = "mesos-slave-${var.environment}-ec2-sg"
    description = "Mesos slave ${var.environment} SG"
    vpc_id      = "${var.vpc_id}"
}
resource "aws_security_group_rule" "mesos-slave-ec2-sg-allowallfromself" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    self              = true

    security_group_id = "${aws_security_group.mesos-slave-ec2-sg.id}"
}
resource "aws_security_group_rule" "mesos-slave-ec2-sg-allowallfrommaster" {
    type                     = "ingress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = "${aws_security_group.mesos-master-ec2-sg.id}"

    security_group_id        = "${aws_security_group.mesos-slave-ec2-sg.id}"
}
resource "aws_security_group_rule" "mesos-slave-ec2-sg-allowall" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.mesos-slave-ec2-sg.id}"
}
resource "aws_security_group_rule" "mesos-slave-ec2-sg-allowallfromshared" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["${var.shared_vpc_cidr}"]

    security_group_id = "${aws_security_group.mesos-slave-ec2-sg.id}"
}
