variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}

# Ubuntu 14.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-fce3c696"
  }
}

variable "ips" {
  default = {
    yousef = "193.60.79.171/32"
  }
}
