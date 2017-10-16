variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

# Ubuntu 14.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-fce3c696"
    admin-node-2016-07-15 = "ami-68d8557f"
    debian-jessie-8-4 = "ami-45374b25"
    us-east-1-ubuntu-16-04 = "ami-80861296"
    jenkins-2017-10-04 = "ami-9f1bdee5"
    bitergia-2017-10-16 = "ami-80b381e0"
  }
}

variable "ips" {
  default = {
    yousef = "86.27.78.158/32"
  }
}

variable "aws_availibility_zones" {
  default = {
    us-east-1 = "us-east-1a,us-east-1c,us-east-1d"
    eu-west-1 = "eu-west-1a,eu-west-1b,eu-west-1c"
  }
}

variable "aws_account_id" {
  default = "484535289196"
}

variable "paas-mozilla-community-zone-id" {
  default = "Z1BZGUW286G7FF"
}

variable "ssl_certificates" {
  type = "map"
  default = {
    community-sites-elb-us-east-1 = "arn:aws:acm:us-east-1:484535289196:certificate/6883a4b5-cc8d-4821-a8db-69fa5fc65e02"
    mozilla-org-elb-us-east-1 = "arn:aws:acm:us-east-1:484535289196:certificate/9fd503f9-7999-471c-8498-42fcdb08d668"
    mesos-elb-us-east-1 = "arn:aws:acm:us-east-1:484535289196:certificate/b8dca075-66a1-48fc-9223-f753a504b4f2"
    analytics-us-west-1 = "arn:aws:acm:us-west-1:484535289196:certificate/b09c28f0-a98e-409c-b614-be356e9c593c"
  }
}

variable "unmanaged_role_ids" {
    type = "map"
    default = {
        admin-ec2-role = "AROAJQQ4P767MJJUWKKVK"
        InfosecSecurityAuditRole = "AROAJHELZZZIXWALL3AVS"
    }
}

variable "unmanaged_role_arns" {
    type = "map"
    default = {
        mozdef-logging = "arn:aws:iam::484535289196:policy/SnsMozdefLogsFullAccess"
    }
}
