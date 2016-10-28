resource "aws_security_group" "marathon-efs-sg" {
   name        = "marathon-${var.environment}-efs-sg"
   description = "Marathon EFS ${var.environment} SG"
   vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "marathon-efs-sg-allownfsfromslave" {
    type              = "ingress"
    from_port         = 2049
    to_port           = 2049
    protocol          = "tcp"
    source_security_group_id = "${aws_security_group.mesos-slave-ec2-sg.id}"
    security_group_id = "${aws_security_group.marathon-efs-sg.id}"
}

resource "aws_efs_file_system" "marathon-efs" {
  tags {
    Name = "marathon-efs-${var.environment}"
  }
}

resource "aws_efs_mount_target" "marathon-efs-shared-1a" {
  file_system_id = "${aws_efs_file_system.marathon-efs.id}"
  subnet_id = "${var.subnet1}"
  security_groups = ["${aws_security_group.marathon-efs-sg.id}"]
}

resource "aws_efs_mount_target" "marathon-efs-shared-1c" {
  file_system_id = "${aws_efs_file_system.marathon-efs.id}"
  subnet_id = "${var.subnet2}"
  security_groups = ["${aws_security_group.marathon-efs-sg.id}"]
}

resource "aws_efs_mount_target" "marathon-efs-shared-1d" {
  file_system_id = "${aws_efs_file_system.marathon-efs.id}"
  subnet_id = "${var.subnet3}"
  security_groups = ["${aws_security_group.marathon-efs-sg.id}"]
}

output "marathon-efs-id" {
    value = "${aws_efs_file_system.marathon-efs.id}"
}
