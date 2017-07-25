data "aws_route53_zone" "mozilla-se" {
  name         = "mozilla.se."
  private_zone = true
}
