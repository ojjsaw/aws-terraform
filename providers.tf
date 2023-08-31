# TODO: MongoDB not yet Automated, comment out dlwb-project.tf and apply after manual Atlas setup
# TODO: Terraform s3 backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }
  required_version = ">= 0.13"
}