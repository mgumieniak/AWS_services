variable "network_name"{
  default = "maciej_test"
}

locals {
  vpc_name = "${var.network_name}_vpc"
}

variable "environment" {
  default = "test"
}
