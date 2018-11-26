provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "kubernetes/layer-participant"
  }
}

data "terraform_remote_state" "layer-base" {
  backend = "s3"

  config {
    bucket = "${var.bucket_layer_base}"
    region = "eu-west-1"
    key    = "kubernetes/layer-base"
  }
}

module "participant-bastion" {
  nb-participants           = "${var.nb-participants}"
  vpc_cidr = "${data.terraform_remote_state.layer-base.vpc_cidr}"
  vpc_id = "${data.terraform_remote_state.layer-base.vpc_id}"
  subnet_a = "${data.terraform_remote_state.layer-base.sn_public_a_id}"

  source = "layer-bastion"
}

module "participant-kubespray" {
  nb-participants           = "${var.nb-participants}"
  vpc_cidr = "${data.terraform_remote_state.layer-base.vpc_cidr}"
  vpc_id = "${data.terraform_remote_state.layer-base.vpc_id}"
  subnet_a = "${data.terraform_remote_state.layer-base.sn_public_a_id}"

  source = "layer-bastion"
}

variable "nb-participants" {
  default = 10
}