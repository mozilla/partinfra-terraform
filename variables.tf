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
    community-sites-elb-us-east-1 = "arn:aws:acm:us-east-1:484535289196:certificate/8b9d3a10-4ab1-4dad-9889-66749b899711"
    mozilla-org-elb-us-east-1 = "arn:aws:acm:us-east-1:484535289196:certificate/a70715b1-3134-40b3-ba34-307f998471eb"
    mesos-elb-us-east-1 = "arn:aws:acm:us-east-1:484535289196:certificate/1af91a2d-8fa2-4726-abbd-f321b7a136c3"
    analytics-us-west-1 = "arn:aws:acm:us-west-1:484535289196:certificate/b09c28f0-a98e-409c-b614-be356e9c593c"
  }
}
