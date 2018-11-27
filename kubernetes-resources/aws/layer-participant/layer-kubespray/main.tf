provider "aws" {
  region = "eu-west-1"
}

variable "vpc_cidr" {}

variable "vpc_id" {}

variable "nb-participants" {
  default = 1
}

variable "subnet_a" {}

variable "subnet_b" {}

variable "subnet_c" {}

variable "private_dns_zone" {}
variable "private_dns_zone_id" {}
