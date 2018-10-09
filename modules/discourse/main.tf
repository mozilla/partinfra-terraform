variable "vpc_id" {}
variable "discourse_elasticache_instance_size" {}
variable "elasticache_subnet_group" {}
variable "service_security_group_id" {}
variable "environment" {}
variable "fqdn" {}
variable "ssl_certificate" {}

resource "aws_security_group" "discourse-redis-sg" {
    name                     = "discourse-redis-${var.environment}-sg"
    description              = "discourse ${var.environment} elasticache SG"
    vpc_id                   = "${var.vpc_id}"
}

resource "aws_security_group_rule" "discourse-redis-sg-allowredisfromslaves" {
    type                     = "ingress"
    from_port                = 6379
    to_port                  = 6379
    protocol                 = "tcp"
    source_security_group_id = "${var.service_security_group_id}"
    security_group_id        = "${aws_security_group.discourse-redis-sg.id}"
}

resource "aws_security_group_rule" "discourse-redis-sg-allowegress" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = "${var.service_security_group_id}"
    security_group_id        = "${aws_security_group.discourse-redis-sg.id}"
}

resource "aws_elasticache_cluster" "discourse-redis-ec" {
    cluster_id                 = "discourse-${var.environment}"
    engine                     = "redis"
    engine_version             = "2.8.24"
    node_type                  = "${var.discourse_elasticache_instance_size}"
    port                       = 6379
    num_cache_nodes            = 1
    parameter_group_name       = "default.redis2.8"
    subnet_group_name          = "${var.elasticache_subnet_group}"
    security_group_ids         = ["${aws_security_group.discourse-redis-sg.id}"]
    tags {
        Name                   = "discourse-${var.environment}-redis"
        app                    = "redis"
        env                    = "${var.environment}"
        project                = "discourse"
    }
}

resource "aws_s3_bucket" "discourse-content" {
    bucket = "discourse-paas-${var.environment}-content"
    acl = "private"

    lifecycle_rule {
        id = "purge_tombstone"
        prefix = "tombstone/"
        enabled = true
        expiration {
            days = 30
        }
    }

    tags {
        Name = "discourse-paas-${var.environment}-content"
        app = "discourse"
        env = "${var.environment}"
        project = "discourse"
    }
}

resource "aws_cloudfront_distribution" "discourse-cdn" {
  origin {
    domain_name = "${var.fqdn}"
    origin_id   = "discourse-pull-origin"
    origin_path = ""
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only" # Only talk to the origin over HTTPS
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  comment             = "Discourse ${var.environment} CDN"
  default_root_object = "index.html"

  aliases = ["cdn-${var.environment}.discourse.mozilla-community.org"]
  price_class = "PriceClass_200"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "discourse-pull-origin"
    compress         = "true"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 360
    max_ttl                = 3600
  }

  restrictions {
    geo_restriction {
        restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.ssl_certificate}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code = 404
  }
}
