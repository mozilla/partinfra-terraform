data "aws_route53_zone" "mozillaindia-org" {
  name         = "mozillaindia.org."
  private_zone = true
}
