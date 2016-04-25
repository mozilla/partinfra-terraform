resource "aws_s3_bucket" "partinfra-tfsync" {
    bucket = "partinfra-tfsync"
    acl = "private"

    tags {
        Name = "partinfra-tfsync"
        Environment = "shared"
    }
}
