resource "aws_iam_instance_profile" "admin-ec2-profile" {
    name = "admin-ec2-profile"
    roles = ["admin-ec2-role"]
}

resource "aws_security_group" "admin-ec2-sg" {
    name                    = "admin-ec2-sg"
    description             = "admin SG"
    vpc_id                  = "${aws_vpc.apps-shared-vpc.id}"
}

resource "aws_security_group_rule" "admin-ec2-sg-allowall" {
    type                    = "ingress"
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    cidr_blocks             = ["${aws_vpc.apps-staging-vpc.cidr_block}",
                               "${aws_vpc.apps-production-vpc.cidr_block}",
                               "${aws_vpc.apps-shared-vpc.cidr_block}"]
    security_group_id       = "${aws_security_group.admin-ec2-sg.id}"
}

resource "aws_security_group_rule" "admin-ec2-sg-allowallhttp" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    cidr_blocks              = ["${aws_vpc.apps-shared-vpc.cidr_block}"]
    security_group_id        = "${aws_security_group.admin-ec2-sg.id}"
}

resource "aws_security_group_rule" "admin-ec2-sg-allowhttpfromelb" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.admin-elb-sg.id}"

    security_group_id        = "${aws_security_group.admin-ec2-sg.id}"
}

resource "aws_security_group_rule" "admin-ec2-sg-allowallegress" {
    type                    = "egress"
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
    security_group_id       = "${aws_security_group.admin-ec2-sg.id}"
}

resource "aws_instance" "admin-ec2" {
    ami                     = "${lookup(var.aws_amis, "admin-node-2016-07-15")}"  # For bug 1285306
    instance_type           = "t2.micro"
    disable_api_termination = true
    key_name                = "ansible"
    vpc_security_group_ids  = ["${aws_security_group.admin-ec2-sg.id}"]
    subnet_id               = "${aws_subnet.apps-shared-1c.id}"
    iam_instance_profile    = "${aws_iam_instance_profile.admin-ec2-profile.name}"

    root_block_device {
      volume_type = "standard"
      volume_size = 20
    }

    tags {
        Name                = "admin"
        app                 = "jenkins"
        env                 = "shared"
        project             = "partinfra"
    }
}

resource "aws_security_group" "admin-elb-sg" {
    name        = "admin-elb-sg"
    description = "Admin ELB SG"
    vpc_id      = "${aws_vpc.apps-shared-vpc.id}"
}


resource "aws_security_group_rule" "admin-elb-sg-allowhttps" {
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = [
        "${aws_vpc.apps-shared-vpc.cidr_block}",
        "${aws_vpc.apps-staging-vpc.cidr_block}",
        "${aws_vpc.apps-production-vpc.cidr_block}"
    ]

    security_group_id = "${aws_security_group.admin-elb-sg.id}"
}

resource "aws_security_group_rule" "admin-elb-sg-allowall" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = [
      "${aws_vpc.apps-shared-vpc.cidr_block}",
      "${aws_vpc.apps-staging-vpc.cidr_block}",
      "${aws_vpc.apps-production-vpc.cidr_block}"
    ]

    security_group_id = "${aws_security_group.admin-elb-sg.id}"
}

resource "aws_elb" "admin-elb" {
  name                        = "admin-elb"
  security_groups             = ["${aws_security_group.admin-elb-sg.id}"]
  subnets                     = ["${aws_subnet.apps-shared-1c.id}"]
  internal                    = true

  listener {
    instance_port             = 80
    instance_protocol         = "http"
    lb_port                   = 443
    lb_protocol               = "https"
    ssl_certificate_id        = "arn:aws:acm:${var.aws_region}:${var.aws_account_id}:certificate/1af91a2d-8fa2-4726-abbd-f321b7a136c3"
  }

  health_check {
    healthy_threshold         = 2
    unhealthy_threshold       = 2
    timeout                   = 3
    target                    = "TCP:80"
    interval                  = 30
  }

  instances = ["${aws_instance.admin-ec2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name                      = "admin-elb"
    app                       = "jenkins"
    env                       = "shared"
  }
}
