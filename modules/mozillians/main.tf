variable "environment" {}
variable "vpc_id" {}
variable "service_security_group_id" {}
variable "elasticache_redis_instance_size" {}
variable "elasticache_memcached_instance_size" {}
variable "elasticache_subnet_group" {}
variable "elasticsearch_arn" {}
variable "cdn_origin_domain_name" {}
variable "cdn_alias" {}
variable "ssl_certificate" {}

resource "aws_security_group" "mozillians-redis-sg" {
    name                     = "mozillians-redis-${var.environment}-sg"
    description              = "mozillians ${var.environment} elasticache SG"
    vpc_id                   = "${var.vpc_id}"
}

resource "aws_security_group_rule" "mozillians-redis-sg-allowredisfromslaves" {
    type                     = "ingress"
    from_port                = 6379
    to_port                  = 6379
    protocol                 = "tcp"
    source_security_group_id = "${var.service_security_group_id}"
    security_group_id        = "${aws_security_group.mozillians-redis-sg.id}"
}

resource "aws_security_group_rule" "mozillians-redis-sg-allowmemcachedfromslaves" {
    type                     = "ingress"
    from_port                = 11211
    to_port                  = 11211
    protocol                 = "tcp"
    source_security_group_id = "${var.service_security_group_id}"
    security_group_id        = "${aws_security_group.mozillians-redis-sg.id}"
}

resource "aws_security_group_rule" "mozillians-redis-sg-allowegress" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    source_security_group_id = "${var.service_security_group_id}"
    security_group_id        = "${aws_security_group.mozillians-redis-sg.id}"
}

resource "aws_elasticache_cluster" "mozillians-redis-ec" {
    cluster_id                 = "mozillians-${var.environment}"
    engine                     = "redis"
    engine_version             = "2.8.24"
    node_type                  = "${var.elasticache_redis_instance_size}"
    port                       = 6379
    num_cache_nodes            = 1
    parameter_group_name       = "default.redis2.8"
    subnet_group_name          = "${var.elasticache_subnet_group}"
    security_group_ids         = ["${aws_security_group.mozillians-redis-sg.id}"]
    tags {
        Name                   = "mozillians-${var.environment}-redis"
        app                    = "redis"
        env                    = "${var.environment}"
        project                = "mozillians"
    }
}

resource "aws_s3_bucket" "exports-bucket" {
    bucket = "mozillians-${var.environment}-exports"
    acl = "private"

    tags = {
        Name = "mozillians-${var.environment}-exports"
        app = "mozillians"
        env = "${var.environment}"
        project = "mozillians"
    }
}

resource "aws_elasticache_cluster" "mozillians-memcached-ec" {
    cluster_id                 = "mozcache-${var.environment}"
    engine                     = "memcached"
    engine_version             = "1.4.34"
    node_type                  = "${var.elasticache_memcached_instance_size}"
    port                       = 11211
    num_cache_nodes            = 1
    parameter_group_name       = "default.memcached1.4"
    subnet_group_name          = "${var.elasticache_subnet_group}"
    security_group_ids         = ["${aws_security_group.mozillians-redis-sg.id}"]
    tags {
        Name                   = "mozillians-${var.environment}-memcached"
        app                    = "memcached"
        env                    = "${var.environment}"
        project                = "mozillians"
    }
}

module "media-cdn" {
  source              = "git://github.com/mozilla/partinfra-terraform-cloudfrontssl.git"

  origin_domain_name  = "${var.cdn_origin_domain_name}"
  origin_path         = ""
  origin_id           = "mozillians-${var.environment}"
  alias               = "${var.cdn_alias}"
  acm_certificate_arn = "${var.ssl_certificate}"
}
