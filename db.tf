variable "mysql-shared-db_password" {}
variable "postgres-shared-db_password" {}
variable "mysql-mozillians-db_password" {}

resource "aws_db_subnet_group" "apps-shared-rds-subnetgroup" {
    name = "apps-shared-rds-subnetgroup"
    description = "RDS subnet group for shared VPC"
    subnet_ids = ["${aws_subnet.apps-shared-1a.id}",
                  "${aws_subnet.apps-shared-1c.id}",
                  "${aws_subnet.apps-shared-1d.id}"]
    tags {
        Name = "apps-shared-rds-subnetgroup"
    }
}

resource "aws_db_subnet_group" "apps-production-rds-subnetgroup" {
    name = "apps-production-rds-subnetgroup"
    description = "RDS subnet group for production VPC"
    subnet_ids = ["${aws_subnet.apps-production-1a.id}",
                  "${aws_subnet.apps-production-1c.id}",
                  "${aws_subnet.apps-production-1d.id}"]
    tags {
        Name = "apps-production-rds-subnetgroup"
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

resource "aws_security_group_rule" "shared-rds-sg-allowpostgresfromprod" {
    type              = "ingress"
    from_port         = 5432
    to_port           = 5432
    protocol          = "tcp"
    source_security_group_id = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"

    security_group_id = "${aws_security_group.shared-rds-sg.id}"
}

resource "aws_security_group_rule" "shared-rds-sg-allowpostgresfromstaging" {
    type              = "ingress"
    from_port         = 5432
    to_port           = 5432
    protocol          = "tcp"
    source_security_group_id = "${module.mesos-cluster-staging.mesos-cluster-slave-sg-id}"

    security_group_id = "${aws_security_group.shared-rds-sg.id}"
}

resource "aws_db_instance" "mysql-shared-db" {
    allocated_storage    = 40
    engine               = "mysql"
    engine_version       = "5.6.27"
    instance_class       = "db.t2.small"
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

resource "aws_route53_record" "mysql-shared-dns" {
    zone_id =  "${var.paas-mozilla-community-zone-id}"
    name = "mysql-shared-db"
    type = "CNAME"
    ttl = 300
    records = ["${aws_db_instance.mysql-shared-db.address}"]
}

resource "aws_db_instance" "postgres-shared-db" {
    identifier                = "postgres-shared-db"
    allocated_storage         = 50
    engine                    = "postgres"
    engine_version            = "9.5.10"
    instance_class            = "db.m4.xlarge"
    publicly_accessible       = false
    backup_retention_period   = 7
    apply_immediately         = true
    multi_az                  = true
    storage_type              = "gp2"
    final_snapshot_identifier = "postgres-shared-db-final"
    name                      = "postgresshareddb"
    username                  = "root"
    password                  = "${var.postgres-shared-db_password}"
    vpc_security_group_ids    = ["${aws_security_group.shared-rds-sg.id}"]
    db_subnet_group_name      = "${aws_db_subnet_group.apps-shared-rds-subnetgroup.name}"
    parameter_group_name      = "default.postgres9.5"
    copy_tags_to_snapshot     = true

    tags {
        Name = "postgres-shared-db"
        app = "postgres"
        env = "shared"
        project = "partinfra"
    }
}

resource "aws_route53_record" "postgres-shared-dns" {
    zone_id =  "${var.paas-mozilla-community-zone-id}"
    name    = "postgres-shared-db"
    type    = "CNAME"
    ttl     = 300
    records = ["${aws_db_instance.postgres-shared-db.address}"]
}

# Mozillians production DB
resource "aws_security_group" "mozillians-prod-rds-sg" {
    name        = "mozillians-prod-rds-sg"
    description = "Mozillians production RDS SG"
    vpc_id      = "${aws_vpc.apps-production-vpc.id}"
}

resource "aws_security_group_rule" "mozillians-rds-sg-allowmysqlfromprod" {
    type              = "ingress"
    from_port         = 3306
    to_port           = 3306
    protocol          = "tcp"
    source_security_group_id = "${aws_security_group.mozillians-slave-ec2-sg.id}"

    security_group_id = "${aws_security_group.mozillians-prod-rds-sg.id}"
}

resource "aws_db_instance" "mysql-mozillians-db" {
    allocated_storage    = 5
    engine               = "mysql"
    engine_version       = "5.6.40"
    instance_class       = "db.t2.medium"
    publicly_accessible  = false
    backup_retention_period = 14
    apply_immediately    = true
    multi_az             = true
    storage_type         = "gp2"
    final_snapshot_identifier = "mysql-mozillians-db-final"
    name                 = "mozilliansdb"
    username             = "root"
    password             = "${var.mysql-mozillians-db_password}"
    vpc_security_group_ids = ["${aws_security_group.mozillians-prod-rds-sg.id}"]
    db_subnet_group_name = "${aws_db_subnet_group.apps-production-rds-subnetgroup.name}"
    parameter_group_name = "default.mysql5.6"
    tags {
        Name                = "mysql-mozillians-db"
        app                 = "mysql"
        env                 = "production"
        project             = "mozillians"
    }
}
