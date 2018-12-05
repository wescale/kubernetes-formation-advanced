provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "wescale-training-terraform"
    region = "eu-west-1"
    key    = "kubernetes/layer-participant"
  }
}

data "terraform_remote_state" "layer-base" {
  backend = "s3"

  config {
    bucket = "wescale-training-terraform"
    region = "eu-west-1"
    key    = "kubernetes/layer-base"
  }
}

module "participant-bastion" {
  nb-participants = "${var.nb-participants}"
  vpc_cidr        = "${data.terraform_remote_state.layer-base.vpc_cidr}"
  vpc_id          = "${data.terraform_remote_state.layer-base.vpc_id}"
  subnet_a        = "${data.terraform_remote_state.layer-base.sn_public_a_id}"

  source = "layer-bastion"
}

module "participant-kubespray" {
  nb-participants = "${var.nb-participants}"
  vpc_cidr        = "${data.terraform_remote_state.layer-base.vpc_cidr}"
  vpc_id          = "${data.terraform_remote_state.layer-base.vpc_id}"
  subnet_a        = "${data.terraform_remote_state.layer-base.sn_private_a_id}"
  subnet_b        = "${data.terraform_remote_state.layer-base.sn_private_b_id}"
  subnet_c        = "${data.terraform_remote_state.layer-base.sn_private_c_id}"
  private_dns_zone = "${data.terraform_remote_state.layer-base.private_dns_zone}"
  private_dns_zone_id = "${data.terraform_remote_state.layer-base.private_dns_zone_id}"

  source = "layer-kubespray"
}

output "list_bastion" {
  value = "${module.participant-bastion.list_bastion}"
}

variable "nb-participants" {
  default = 10
}
