variable "mysql-shared-db_password" {}

resource "aws_db_subnet_group" "apps-shared-rds-subnetgroup" {
    name = "apps-shared-rds-subnetgroup"
    description = "RDS subnet group for shared VPC"
    subnet_ids = ["${aws_subnet.apps-shared-1a.id}", "${aws_subnet.apps-shared-1c.id}", "${aws_subnet.apps-shared-1d.id}"]
    tags {
        Name = "apps-shared-rds-subnetgroup"
    }
}

resource "aws_security_group" "shared-rds-sg" {
    name        = "shared-rds-sg"
    description = "Shared RDS SG"
    vpc_id      = "${aws_vpc.apps-shared-vpc.id}"
}

resource "aws_security_group_rule" "shared-rds-sg-allowmysqlfromprod" {
    type              = "ingress"
    from_port         = 3306
    to_port           = 3306
    protocol          = "tcp"
    source_security_group_id = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"

    security_group_id = "${aws_security_group.shared-rds-sg.id}"
}

resource "aws_security_group_rule" "shared-rds-sg-allowmysqlfromstaging" {
    type              = "ingress"
    from_port         = 3306
    to_port           = 3306
    protocol          = "tcp"
    source_security_group_id = "${module.mesos-cluster-staging.mesos-cluster-slave-sg-id}"

    security_group_id = "${aws_security_group.shared-rds-sg.id}"
}


resource "aws_db_instance" "mysql-shared-db" {
  allocated_storage    = 40
  engine               = "mysql"
  engine_version       = "5.6.27"
  instance_class       = "db.t2.medium"
  publicly_accessible  = false
  backup_retention_period = 7
  apply_immediately    = true
  multi_az             = true
  storage_type         = "gp2"
  final_snapshot_identifier = "mysql-shared-db-final"
  name                 = "mysqlshareddb"
  username             = "root"
  password             = "${var.mysql-shared-db_password}"
  vpc_security_group_ids = ["${aws_security_group.shared-rds-sg.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.apps-shared-rds-subnetgroup.name}"
  parameter_group_name = "default.mysql5.6"
  tags {
      Name                = "mysql-shared-db"
      app                 = "mysql"
      env                 = "shared"
      project             = "partinfra"
  }
}
