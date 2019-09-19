resource "aws_security_group" "mcws-confluence-public-ec2-sg" {
    provider    = "aws.us-east-2"
    name        = "mcws-confluence-public-ec2-sg"
    description = "MCWS Confluence public SG"
}

resource "aws_security_group_rule" "confluence-public-allow-http-ingress" {
    provider          = "aws.us-east-2"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "80"
    to_port           = "80"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "confluence-public-allow-https-ingress" {
    provider          = "aws.us-east-2"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "443"
    to_port           = "443"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "confluence-public-allow-alt-http-ingress" {
    provider          = "aws.us-east-2"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "8080"
    to_port           = "8080"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "confluence-public-allow-ssh-ingress" {
    provider          = "aws.us-east-2"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "22"
    to_port           = "22"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "confluence-public-allow-all-egress-tcp" {
    provider          = "aws.us-east-2"
    type              = "egress"
    protocol          = "tcp"
    from_port         = "0"
    to_port           = "65535"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}"
}

resource "aws_security_group_rule" "confluence-public-allow-all-egress-udp" {
    provider          = "aws.us-east-2"
    type              = "egress"
    protocol          = "udp"
    from_port         = "0"
    to_port           = "65535"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}"
}

resource "aws_instance" "mcws-confluence" {
    provider          = "aws.us-east-2"
    provider          = "aws.us-east-2"
    ami               = "ami-0f65671a86f061fcd"
    instance_type     = "t2.large"
    key_name          = "mcws"
    security_groups   = ["mcws-confluence-public-ec2-sg"]
    disable_api_termination = true

    root_block_device {
      volume_type     = "gp2"
      volume_size     = 80
    }

    tags {
      Name            = "mcws_confluence"
      app             = "confluence"
      project         = "mcws"
    }
}
