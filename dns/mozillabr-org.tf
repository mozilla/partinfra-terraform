data "aws_route53_zone" "mozillabr-org" {
  name         = "mozillabr.org."
  private_zone = true
}
