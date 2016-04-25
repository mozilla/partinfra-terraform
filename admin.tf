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

resource "aws_security_group_rule" "admin-ec2-sg-allowallegress" {
    type                    = "egress"
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
    security_group_id       = "${aws_security_group.admin-ec2-sg.id}"
}

resource "aws_instance" "admin-ec2" {
    ami                     = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type           = "t2.micro"
    disable_api_termination = true
    key_name                = "ansible"
    vpc_security_group_ids  = ["${aws_security_group.admin-ec2-sg.id}"]
    subnet_id               = "${aws_subnet.apps-shared-1c.id}"

    tags {
        Name                = "admin"
        app                 = "jenkins"
        env                 = "shared"
        project             = "partinfra"
    }
}
