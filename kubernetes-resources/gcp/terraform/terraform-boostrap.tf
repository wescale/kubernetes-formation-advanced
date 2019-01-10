terraform {
  backend "gcs" {
    bucket  = "sandbox-training-terraform-states"
    prefix  = "kubernetes-formation-advanced"
    project = "sandbox-training-225413"
    region  = "europe-west1"
  }
}

variable "nb-participants" {
  default = 1
}

variable "region" {
  default = "europe-west1"
}
