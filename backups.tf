resource "aws_s3_bucket" "jenkins-duplicity-backup" {
    bucket = "jenkins-duplicity-backup"
    acl = "private"

    tags = {
        Name = "jenkins-duplicity-backup"
        app = "duplicity"
        project = "backup"
    }
}

resource "aws_s3_bucket" "jenkins-public-duplicity-backup" {
    bucket = "jenkins-public-duplicity-backup"
    acl = "private"

    tags = {
        Name = "jenkins-public-duplicity-backup"
        app = "duplicity"
        project = "backup"
    }
}
