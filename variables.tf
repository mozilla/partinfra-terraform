variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

# Ubuntu 14.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-fce3c696"
    admin-node-2016-07-15 = "ami-68d8557f"
    debian-jessie-8-4 = "ami-c8bda8a2"
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
