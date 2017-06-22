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
    mozilla-org-elb-us-east-1 = "arn:aws:acm:us-east-1:484535289196:certificate/73b4dc75-9193-4884-9967-7c575e640a69"
    mesos-elb-us-east-1 = "arn:aws:acm:us-east-1:484535289196:certificate/1af91a2d-8fa2-4726-abbd-f321b7a136c3"
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
