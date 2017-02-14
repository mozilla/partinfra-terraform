resource "aws_s3_bucket" "discourse-email-in" {
    bucket = "discourse-paas-${var.environment}-emails"
    acl = "private"

    tags {
        Name = "discourse-paas-${var.environment}-emails"
        app = "discourse"
        env = "${var.environment}"
        project = "discourse"
    }
}

resource "aws_iam_role" "discourse-lambda-role" {
    name = "discourse-lambda-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetObject"
          ],
          "Resource": "${aws_s3_bucket.discourse-email-in.arn}"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetObject"
          ],
          "Resource": "${var.lambda-functions-bucket}"
      }
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "discourse-email-handler" {
    s3_bucket = "${var.lambda-functions-bucket}"
    s3_key = "discourse_email_handler_${var.environment}.zip"
    function_name = "discourse-${var.environment}-email-handler"
    role = "${aws_iam_role.discourse-lambda-role.arn}"
    handler = "exports.discourseEmailHandler"
    memory_size = 128
    runtime = "python2.7"

    environment {
        variables = {
            DISCOURSE_EMAIL_IN_BUCKET = "${aws_s3_bucket.discourse-email-in.id}"
            DISCOURSE_API_KEY = "${var.discourse_api_key}"
            DISCOURSE_URL = "${var.fqdn}"
            DISCOURSE_API_USERNAME = "system"
        }
    }
}
