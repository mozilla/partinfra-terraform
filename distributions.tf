module "activate-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/activate.mozilla.community"
  origin_id           = "gh-pages-activate-mozilla-community"
  alias               = "activate.mozilla.community"
  comment             = "Bug 1287738"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
}

module "campus-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/mozilla-campus-clubs"
  origin_id           = "gh-pages-campus-mozilla-community"
  alias               = "campus.mozilla.community"
  comment             = "Bug 1301082"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
}

module "badges-mozilla-org" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "s3.amazonaws.com"
  origin_path         = "/badges.mozilla.org"
  origin_id           = "s3-badges-mozilla-org"
  alias               = "badges.mozilla.org"
  comment             = "Bug 1230266"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mozilla-org-elb-${var.aws_region}")}"
}

module "mozillaindia-org" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_path  = "devs.mozillaindia.org"
  origin_path         = "/homepage"
  origin_id           = "gh-pages-dev-mozillaindia-org"
  alias               = "mozillaindia.org"
  comment             = "Bug 1344680"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
  }
}
