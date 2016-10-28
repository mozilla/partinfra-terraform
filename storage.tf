resource "aws_security_group" "jenkins-efs-sg" {
   name        = "jenkins-efs-sg"
   description = "Jenkins EFS SG"
   vpc_id      = "${aws_vpc.apps-shared-vpc.id}"
}

resource "aws_security_group_rule" "jenkins-efs-sg-allownfsfromadmin" {
    type              = "ingress"
    from_port         = 2049
    to_port           = 2049
    protocol          = "tcp"
    source_security_group_id = "${aws_security_group.admin-ec2-sg.id}"
    security_group_id = "${aws_security_group.jenkins-efs-sg.id}"
}

resource "aws_efs_file_system" "jenkins-efs" {
  tags {
    Name = "jenkins-efs"
  }
}

resource "aws_efs_mount_target" "jenkins-efs-shared-1a" {
  file_system_id = "${aws_efs_file_system.jenkins-efs.id}"
  subnet_id = "${aws_subnet.apps-shared-1a.id}"
  security_groups = ["${aws_security_group.jenkins-efs-sg.id}"]
}

resource "aws_efs_mount_target" "jenkins-efs-shared-1c" {
  file_system_id = "${aws_efs_file_system.jenkins-efs.id}"
  subnet_id = "${aws_subnet.apps-shared-1c.id}"
  security_groups = ["${aws_security_group.jenkins-efs-sg.id}"]
}

resource "aws_efs_mount_target" "jenkins-efs-shared-1d" {
  file_system_id = "${aws_efs_file_system.jenkins-efs.id}"
  subnet_id = "${aws_subnet.apps-shared-1d.id}"
  security_groups = ["${aws_security_group.jenkins-efs-sg.id}"]
}

# Jenkins public EFS
resource "aws_security_group" "jenkins-public-efs-sg" {
   name        = "jenkins-public-efs-sg"
   description = "jenkins-public EFS SG"
   vpc_id      = "${aws_vpc.apps-shared-vpc.id}"
}

resource "aws_security_group_rule" "jenkins-public-efs-sg-allownfsfromjenkins" {
    type              = "ingress"
    from_port         = 2049
    to_port           = 2049
    protocol          = "tcp"
    source_security_group_id = "${aws_security_group.jenkins-public-ec2-sg.id}"
    security_group_id = "${aws_security_group.jenkins-public-efs-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-efs-sg-allownfsfromadmin" {
    type              = "ingress"
    from_port         = 2049
    to_port           = 2049
    protocol          = "tcp"
    source_security_group_id = "${aws_security_group.admin-ec2-sg.id}"
    security_group_id = "${aws_security_group.jenkins-public-efs-sg.id}"
}

resource "aws_efs_file_system" "jenkins-public-efs" {
  tags {
    Name = "jenkins-public-efs"
  }
}

resource "aws_efs_mount_target" "jenkins-public-efs-shared-1a" {
  file_system_id = "${aws_efs_file_system.jenkins-public-efs.id}"
  subnet_id = "${aws_subnet.apps-shared-1a.id}"
  security_groups = ["${aws_security_group.jenkins-public-efs-sg.id}"]
}

resource "aws_efs_mount_target" "jenkins-public-efs-shared-1c" {
  file_system_id = "${aws_efs_file_system.jenkins-public-efs.id}"
  subnet_id = "${aws_subnet.apps-shared-1c.id}"
  security_groups = ["${aws_security_group.jenkins-public-efs-sg.id}"]
}

resource "aws_efs_mount_target" "jenkins-public-efs-shared-1d" {
  file_system_id = "${aws_efs_file_system.jenkins-public-efs.id}"
  subnet_id = "${aws_subnet.apps-shared-1d.id}"
  security_groups = ["${aws_security_group.jenkins-public-efs-sg.id}"]
}

# EFS mount targets for `marathon-efs` backups

resource "aws_security_group" "marathon-admin-efs-sg" {
    name = "marathon-admin-efs-sg"
    description = "Marathon admin EFS SG for backups"
    vpc_id = "${aws_vpc.apps-shared-vpc.id}"
}

resource "aws_security_group_rule" "marathon-admin-efs-sg-allownfsfromadmin" {
    type              = "ingress"
    from_port         = 2049
    to_port           = 2049
    protocol          = "tcp"
    source_security_group_id = "${aws_security_group.admin-ec2-sg.id}"
    security_group_id = "${aws_security_group.marathon-admin-efs-sg.id}"
}

resource "aws_efs_mount_target" "marathon-prod-efs-admin-1a" {
    file_system_id = "${module.mesos-cluster-production.marathon-efs-id}"
    subnet_id = "${aws_subnet.apps-shared-1a.id}"
    security_groups = ["${aws_security_group.marathon-admin-efs-sg.id}"]
}

resource "aws_efs_mount_target" "marathon-prod-efs-admin-1c" {
    file_system_id = "${module.mesos-cluster-production.marathon-efs-id}"
    subnet_id = "${aws_subnet.apps-shared-1c.id}"
    security_groups = ["${aws_security_group.marathon-admin-efs-sg.id}"]
}

resource "aws_efs_mount_target" "marathon-prod-efs-admin-1d" {
    file_system_id = "${module.mesos-cluster-production.marathon-efs-id}"
    subnet_id = "${aws_subnet.apps-shared-1d.id}"
    security_groups = ["${aws_security_group.marathon-admin-efs-sg.id}"]
}

resource "aws_efs_mount_target" "marathon-staging-efs-admin-1a" {
    file_system_id = "${module.mesos-cluster-staging.marathon-efs-id}"
    subnet_id = "${aws_subnet.apps-shared-1a.id}"
    security_groups = ["${aws_security_group.marathon-admin-efs-sg.id}"]
}

resource "aws_efs_mount_target" "marathon-staging-efs-admin-1c" {
    file_system_id = "${module.mesos-cluster-staging.marathon-efs-id}"
    subnet_id = "${aws_subnet.apps-shared-1c.id}"
    security_groups = ["${aws_security_group.marathon-admin-efs-sg.id}"]
}

resource "aws_efs_mount_target" "marathon-staging-efs-admin-1d" {
    file_system_id = "${module.mesos-cluster-staging.marathon-efs-id}"
    subnet_id = "${aws_subnet.apps-shared-1d.id}"
    security_groups = ["${aws_security_group.marathon-admin-efs-sg.id}"]
}
