resource "aws_security_group" "mcws-confluence-public-ec2-sg" {
    provider    = "aws.us-east-2"
    name        = "mcws-confluence-public-ec2-sg"
    description = "MCWS Confluence public SG"
}
resource "aws_security_group_rule" "confluence-public-allow-http-ingress" {
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "80"
    to_port           = "80"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}" 
}


resource "aws_security_group_rule" "confluence-public-allow-https-ingress" {
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "443"
    to_port           = "443"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}" 
}


resource "aws_security_group_rule" "confluence-public-allow-alt-http-ingress" {
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "8080"
    to_port           = "8080"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}" 
}


resource "aws_security_group_rule" "confluence-public-allow-ssh-ingress" {
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "22"
    to_port           = "22"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}" 
}


resource "aws_security_group_rule" "confluence-public-allow-all-egress-tcp" {
    type              = "egress"
    protocol          = "tcp"
    from_port         = "0"
    to_port           = "0"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}" 
}
resource "aws_security_group_rule" "confluence-public-allow-all-egress-udp" {
    type              = "egress"
    protocol          = "udp"
    from_port         = "0"
    to_port           = "0"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.mcws-confluence-public-ec2-sg.id}" 
}

resource "aws_instance" "mcws-confluence" {
    provider          = "aws.us-east-2"
    ami               = "ubuntu"
    instance_type     = "t2.medium"
    key_name          = "ansible"
    security_groups   = ["mcws-confluence-public-ec2-sg"]
}
