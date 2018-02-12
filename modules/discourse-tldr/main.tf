variable "environment" {}
variable "discourse_tldr_bucket" {
  default = "discourse-tldr-lambda"
}
variable "discourse_tldr_bucket_arn" {
  default = "arn:aws:s3:::discourse-tldr-lambda"
}
variable "discourse_tldr_api_key" {}
variable "discourse_tldr_api_username" {}
variable "discourse_tldr_category" {}
variable "discourse_tldr_url" {}
variable "discourse_tldr_version" {
  default = "v0"
}

data "aws_iam_policy_document" "discourse-tldr-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "discourse-tldr-role-policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${var.discourse_tldr_bucket_arn}", "${var.discourse_tldr_bucket_arn}/*"]
  }
}

resource "aws_iam_role" "discourse-tldr" {
  name = "discourse-${var.environment}-tldr-lambda-role"
  assume_role_policy = "${data.aws_iam_policy_document.discourse-tldr-assume-role.json}"
}

resource "aws_iam_role_policy_attachment" "discourse-tldr" {
  role = "${aws_iam_role.discourse-tldr.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "discourse-tldr-s3" {
  name = "discourse-${var.environment}-tldr-s3-policy"
  policy = "${data.aws_iam_policy_document.discourse-tldr-role-policy.json}"
  role = "${aws_iam_role.discourse-tldr.id}"
}

resource "aws_lambda_function" "discourse-tldr" {
  function_name = "discourse-${var.environment}-tldr"

  s3_bucket = "${var.discourse_tldr_bucket}"
  s3_key = "lambda-functions/${var.discourse_tldr_version}/post-newsletter.zip"

  role = "${aws_iam_role.discourse-tldr.arn}"
  handler = "index.handler"
  runtime = "nodejs6.10"

  environment {
    variables = {
      DISCOURSE_TLDR_BUCKET = "${var.discourse_tldr_bucket}"
      DISCOURSE_TLDR_API_KEY = "${var.discourse_tldr_api_key}"
      DISCOURSE_TLDR_API_USERNAME = "${var.discourse_tldr_api_username}"
      DISCOURSE_TLDR_CATEGORY = "${var.discourse_tldr_category}"
      DISCOURSE_TLDR_URL = "${var.discourse_tldr_url}"
    }
  }

  memory_size = 256
  timeout = 20
  publish = true
}

resource "aws_ses_receipt_rule" "discourse-tldr" {
  name          = "discourse-${var.environment}-tldr"
  rule_set_name = "default-rule-set"
  recipients    = ["tldr@discourse.mozilla.community"]
  enabled       = true
  scan_enabled  = true
  after         = "innoprize-hostmaster-email"
  tls_policy    = "Require"

  s3_action {
    bucket_name = "${var.discourse_tldr_bucket}"
    position = 1
  }

  lambda_action {
    function_arn = "${aws_lambda_function.discourse-tldr.arn}"
    invocation_type = "Event"
    position = 2
  }
}
