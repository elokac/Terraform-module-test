terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                   = lookup(var.region, terraform.workspace)
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
}

terraform {
  backend "s3" {
    bucket  = "proph-0cbf88cb0279b26b"
    key     = "proph/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # kms_key_id     = "THE_ID_OF_THE_KMS_KEY"
    dynamodb_table = "terraform-state-lock"
  }
}
