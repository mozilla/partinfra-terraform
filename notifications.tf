variable "victorops_cloudwatch_endpoint" {}

resource "aws_sns_topic" "sns-cloudwatch-partinfra" {
  name = "victorOps-partinfra-topic"
  display_name = "VictorOps Partinfra"
}

resource "aws_sns_topic_subscription" "sns-cloudwatch-target" {
  topic_arn = "${aws_sns_topic.sns-cloudwatch-partinfra.arn}"
  protocol = "https"
  endpoint = "${var.victorops_cloudwatch_endpoint}"
  endpoint_auto_confirms = true
}
