data "aws_route53_zone" "mozilla-lt" {
  name         = "mozilla.lt."
  private_zone = true
}
