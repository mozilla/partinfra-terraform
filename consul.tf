resource "aws_security_group" "consul-shared-ec2-sg" {
    name        = "consul-shared-ec2-sg"
    description = "Consul SG"
    vpc_id      = "${aws_vpc.apps-shared-vpc.id}"
}

resource "aws_security_group_rule" "consul-shared-ec2-sg-allowallfromprodstaging" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${aws_vpc.apps-staging-vpc.cidr_block}", "${aws_vpc.apps-production-vpc.cidr_block}"]

    security_group_id = "${aws_security_group.consul-shared-ec2-sg.id}"
}

resource "aws_security_group_rule" "consul-shared-ec2-sg-allowall" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.consul-shared-ec2-sg.id}"
}

resource "aws_launch_configuration" "consul-shared-ec2-as" {
    name = "consul-shared-ec2-as"
    image_id = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "t1.small"
}
