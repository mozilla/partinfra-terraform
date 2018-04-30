module "activate-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/activate.mozilla.community"
  origin_id           = "gh-pages-activate-mozilla-community"
  alias               = "activate.mozilla.community"
  comment             = "Bug 1287738"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "campus-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/mozilla-campus-clubs"
  origin_id           = "gh-pages-campus-mozilla-community"
  alias               = "campus.mozilla.community"
  comment             = "Bug 1301082"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "badges-mozilla-org" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "s3.amazonaws.com"
  origin_path         = "/badges.mozilla.org"
  origin_id           = "s3-badges-mozilla-org"
  alias               = "badges.mozilla.org"
  comment             = "Bug 1230266"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mozilla-org-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "mozillaindia-org" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "mozillaindia.github.io"
  origin_path         = ""
  origin_id           = "gh-pages-mozillaindia-github-io"
  alias               = "mozillaindia.org"
  comment             = "Bug 1344680"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
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
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "s3.amazonaws.com"
  origin_path         = "/challenge.equalrating.com"
  origin_id           = "s3-challenge-equalrating-com"
  alias               = "challenge.equalrating.com"
  comment             = "parsys/issues/196"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "community-sites-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "firefoxsprint-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/firefox57-sprint"
  origin_id           = "gh-pages-firefoxsprint-mozilla-community"
  alias               = "firefoxsprint.mozilla.community"
  comment             = "github.com/mozilla/parsys/issues/226"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "newfirefox-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/newfirefox.mozilla.community"
  origin_id           = "gh-pages-newfirefox-mozilla-community"
  alias               = "newfirefox.mozilla.community"
  comment             = "github.com/mozilla/parsys/issues/241"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "voice-sprint-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "mozilla.github.io"
  origin_path         = "/common-voice-global-sprint"
  origin_id           = "gh-pages-common-voice-global-sprint"
  alias               = "voice-sprint.mozilla.community"
  comment             = "github.com/mozilla/parsys/issues/320"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "roadshow-rustbr-org" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "rust-br.github.io"
  origin_path         = "/2018-roadshow"
  origin_id           = "gh-pages-roadshow-rust-org"
  alias               = "roadshow.rustbr.org"
  comment             = "bug 1419248"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "roadshow-rustbr-org-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "training-mozilla-community" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "emmairwin.github.io"
  origin_path         = "/learning-open-source"
  origin_id           = "gh-pages-training-mozilla-community"
  alias               = "training.mozilla.community"
  comment             = "mozilla/coss/issues/765"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "mesos-elb-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}

module "livro-rustbr-org" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git?ref=secureheaders"

  origin_domain_name  = "rust-br.github.io"
  origin_path         = "/rust-book-pt-br"
  origin_id           = "gh-pages-livro-rust-org"
  alias               = "livro.rustbr.org"
  comment             = "bug 1437724"
  acm_certificate_arn = "${lookup(var.ssl_certificates, "livro-rustbr-org-${var.aws_region}")}"
  headers {
        enabled = true
        hsts-enabled = true
        x-content-type-enabled = true
        x-frame-options-enabled = true
        x-xss-protection-enabled = true
    }
}
