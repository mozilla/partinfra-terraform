variable "infra_logs_es_iam_policy" {
    type = "string"
    default = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Condition": {
                "IpAddress": {"aws:SourceIp": ["52.91.164.226"]}
            }
        }
    ]
}
CONFIG
}

resource "aws_elasticsearch_domain" "infra-logs-es" {
    domain_name = "infra-logs-es"
    elasticsearch_version = "2.3"
    snapshot_options = {
        automated_snapshot_start_hour = 23
    }

    access_policies = "${var.infra_logs_es_iam_policy}"

    cluster_config = {
        instance_count = 2
        instance_type = "t2.micro.elasticsearch"
        dedicated_master_enabled = false
        zone_awareness_enabled = false
    }

    ebs_options = {
        ebs_enabled = true
        volume_type = "standard"
        volume_size = 10
    }

    tags = {
        Domain = "infra-logs-es"
        app = "elasticsearch"
        env = "shared"
    }
}
