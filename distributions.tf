module "activate-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/activate.mozilla.community"
  origin_id           = "gh-pages-activate-mozilla-community"
  alias               = "activate.mozilla.community"
  comment             = "Bug 1287738"
  acm_certificate_arn = "arn:aws:acm:${var.aws_region}:${var.aws_account_id}:certificate/1af91a2d-8fa2-4726-abbd-f321b7a136c3"
}

module "campus-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/mozilla-campus-clubs"
  origin_id           = "gh-pages-campus-mozilla-community"
  alias               = "campus.mozilla.community"
  comment             = "Bug 1301082"
  acm_certificate_arn = "arn:aws:acm:${var.aws_region}:${var.aws_account_id}:certificate/1af91a2d-8fa2-4726-abbd-f321b7a136c3"
}
