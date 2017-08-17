variable "environment" {}

resource "aws_s3_bucket" "media-uploads" {
    bucket = "coss-${var.environment}-media"
    acl = "public-read"

    tags {
        Name = "coss-${var.environment}-media"
        app = "coss"
        env = "${var.environment}"
        project = "coss"
    }
}
