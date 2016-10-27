resource "aws_s3_bucket" "marathon-duplicity-backups" {
    bucket = "marathon-${var.environment}-duplicity-backup"
    acl = "private"

    tags = {
        Name = "marathon-${var.environment}-duplicity-backup"
        app = "duplicity"
        project = "backup"
        env = "${var.environment}"
    }
}
