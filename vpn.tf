resource "aws_security_group" "openvpn-ec2-sg" {
    name                    = "openvpn-ec2-sg"
    description             = "OpenVPN SG"
    vpc_id                  = "${aws_vpc.apps-shared-vpc.id}"
}
resource "aws_security_group_rule" "openvpn-ec2-sg-allowovpn" {
    type                    = "ingress"
    from_port               = 1194
    to_port                 = 1194
    protocol                = "udp"
    cidr_blocks             = ["0.0.0.0/0"]

    security_group_id       = "${aws_security_group.openvpn-ec2-sg.id}"
}
resource "aws_security_group_rule" "openvpn-ec2-sg-allowssh" {
    type                    = "ingress"
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    cidr_blocks             = ["${var.ips["yousef"]}"]

    security_group_id       = "${aws_security_group.openvpn-ec2-sg.id}"
}
resource "aws_security_group_rule" "openvpn-ec2-sg-allowall" {
    type                    = "egress"
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]

    security_group_id       = "${aws_security_group.openvpn-ec2-sg.id}"
}

resource "aws_instance" "openvpn-ec2" {
    ami                     = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type           = "t2.micro"
    disable_api_termination = true
    key_name                = "ansible"
    vpc_security_group_ids  = ["${aws_security_group.openvpn-ec2-sg.id}"]
    subnet_id               = "${aws_subnet.apps-shared-1c.id}"

    tags {
        Name                = "openvpn"
        app                 = "openvpn"
        env                 = "shared"
        project             = "partinfra"
    }
}
