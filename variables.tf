### Tags
variable "tags" {
  type        = map(string)
  description = "The default tags to apply to all resources."
  default = {
    Owner       = "ojjsaw@gmail.com"
    Project     = "DLWB-BM"
    Environment = "Sandbox"
  }
}

### VPC Vars
variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
  default     = "us-west-2"
}

### ECR Vars
variable "ecr_account_id" {
  type    = string
  default = "868686364197"
}