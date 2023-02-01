terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  shared_credentials_files = ["~/aws/terraform_cred/credentials"]
  shared_config_files      = ["~/aws/terraform_cred/config"]
}

