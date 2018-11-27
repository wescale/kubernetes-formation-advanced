provider "aws" {
  region = "eu-west-1"
}

variable "vpc_cidr" {}

variable "vpc_id" {}

variable "nb-participants" {
  default = 1
}

variable "subnet_a" {}
