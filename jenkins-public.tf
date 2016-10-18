resource "aws_security_group" "jenkins-public-ec2-sg" {
    name                    = "jenkins-public-ec2-sg"
    description             = "jenkins-public SG"
    vpc_id                  = "${aws_vpc.apps-shared-vpc.id}"
}

resource "aws_security_group_rule" "jenkins-public-ec2-sg-allowsharedssh" {
    type                    = "ingress"
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    cidr_blocks             = ["${aws_vpc.apps-shared-vpc.cidr_block}"]
    security_group_id       = "${aws_security_group.jenkins-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-ec2-sg-allowhttpfromjenkins-public-elb" {
    type                     = "ingress"
    from_port                = 8080
    to_port                  = 8080
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.jenkins-public-elb-sg.id}"

    security_group_id        = "${aws_security_group.jenkins-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-elb-sg-allowregistryfromelb" {
    type                     = "ingress"
    from_port                = 5000
    to_port                  = 5000
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.jenkins-public-elb-sg.id}"

    security_group_id        = "${aws_security_group.jenkins-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-elb-sg-allowregistryfromstaging" {
    type                     = "ingress"
    from_port                = 5000
    to_port                  = 5000
    protocol                 = "tcp"
    source_security_group_id = "${module.mesos-cluster-staging.mesos-cluster-slave-sg-id}"
    security_group_id        = "${aws_security_group.jenkins-public-elb-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-elb-sg-allowregistryfromproduction" {
    type                     = "ingress"
    from_port                = 5000
    to_port                  = 5000
    protocol                 = "tcp"
    source_security_group_id = "${module.mesos-cluster-production.mesos-cluster-slave-sg-id}"
    security_group_id        = "${aws_security_group.jenkins-public-elb-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-ec2-sg-allowmesosframework" {
    type                     = "ingress"
    from_port                = 10000
    to_port                  = 65535
    protocol                 = "tcp"
    source_security_group_id = "${module.mesos-cluster-staging.mesos-cluster-master-sg-id}"

    security_group_id        = "${aws_security_group.jenkins-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-ec2-sg-allowjnlpfromslave" {
    type                     = "ingress"
    from_port                = 50000
    to_port                  = 50000
    protocol                 = "tcp"
    source_security_group_id = "${module.mesos-cluster-staging.mesos-cluster-slave-sg-id}"

    security_group_id        = "${aws_security_group.jenkins-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-ec2-sg-allowhttpfromall" {
    type                     = "ingress"
    from_port                = 8080
    to_port                  = 8080
    protocol                 = "tcp"
    cidr_blocks              = [
      "${aws_vpc.apps-shared-vpc.cidr_block}",
      "${aws_vpc.apps-staging-vpc.cidr_block}",
      "${aws_vpc.apps-production-vpc.cidr_block}"
    ]

    security_group_id        = "${aws_security_group.jenkins-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-ec2-sg-allowallegress" {
    type                    = "egress"
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
    security_group_id       = "${aws_security_group.jenkins-public-ec2-sg.id}"
}

resource "aws_instance" "jenkins-public-ec2" {
    ami                     = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type           = "t2.micro"
    disable_api_termination = true
    key_name                = "ansible"
    vpc_security_group_ids  = ["${aws_security_group.jenkins-public-ec2-sg.id}"]
    subnet_id               = "${aws_subnet.apps-shared-1c.id}"

    root_block_device {
      volume_type = "standard"
      volume_size = 20
    }

    tags {
        Name                = "jenkins-public"
        app                 = "jenkins"
        env                 = "shared"
        project             = "partinfra"
    }
}

resource "aws_security_group" "jenkins-public-elb-sg" {
    name        = "jenkins-public-elb-sg"
    description = "jenkins-public ELB SG"
    vpc_id      = "${aws_vpc.apps-shared-vpc.id}"
}


resource "aws_security_group_rule" "jenkins-public-elb-sg-allowhttps" {
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.jenkins-public-elb-sg.id}"
}

resource "aws_security_group_rule" "jenkins-public-elb-sg-allowall" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.jenkins-public-elb-sg.id}"
}

resource "aws_elb" "jenkins-public-elb" {
  name                        = "jenkins-public-elb"
  security_groups             = ["${aws_security_group.jenkins-public-elb-sg.id}"]
  subnets                     = ["${aws_subnet.apps-shared-1c.id}"]
  internal                    = false

  listener {
    instance_port             = 8080
    instance_protocol         = "http"
    lb_port                   = 443
    lb_protocol               = "https"
    ssl_certificate_id        = "arn:aws:acm:${var.aws_region}:${var.aws_account_id}:certificate/1af91a2d-8fa2-4726-abbd-f321b7a136c3"
  }

  listener {
    instance_port             = 5000
    instance_protocol         = "http"
    lb_port                   = 5000
    lb_protocol               = "https"
    ssl_certificate_id        = "arn:aws:acm:${var.aws_region}:${var.aws_account_id}:certificate/1af91a2d-8fa2-4726-abbd-f321b7a136c3"
  }

  health_check {
    healthy_threshold         = 2
    unhealthy_threshold       = 2
    timeout                   = 3
    target                    = "TCP:8080"
    interval                  = 30
  }

  instances = ["${aws_instance.jenkins-public-ec2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name                      = "jenkins-public-elb"
    app                       = "jenkins"
    env                       = "shared"
    project                   = "partinfra"
  }
}
