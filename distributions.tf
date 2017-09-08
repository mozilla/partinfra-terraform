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

  origin_domain_name  = "mozillaindia.github.io"
  origin_path         = "/"
  origin_id           = "gh-pages-mozillaindia-github-io"
  alias               = "mozillaindia.org"
  comment             = "Bug 1344680"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
}

resource "aws_s3_bucket" "equalrating-archive-bucket" {
    bucket = "challenge.equalrating.com"
    acl = "public-read"

    website {
      index_document = "index.html"
    }

    tags = {
        Name = "challenge.equalrating.com"
        project = "equalrating"
    }
}


module "challenge-equalrating-com" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "s3.amazonaws.com"
  origin_path         = "/challenge.equalrating.com"
  origin_id           = "s3-challenge-equalrating-com"
  alias               = "challenge.equalrating.com"
  comment             = "parsys/issues/196"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
}

module "firefoxsprint-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/firefox57-sprint"
  origin_id           = "gh-pages-firefoxsprint-mozilla-community"
  alias               = "firefoxsprint.mozilla.community"
  comment             = "github.com/mozilla/parsys/issues/226"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
}
