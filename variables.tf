/************ Tags ****************/
variable "tags" {
  type        = map(string)
  description = "The default tags to apply to all resources."
  default = {
    Owner       = "ojas.d.sawant@intel.com"
    Project     = "DLWB-BM"
    Environment = "SprintDemo"
  }
}

/************ VPC Vars ****************/
variable "region" {
  type        = string
  description = "The AWS region to deploy the resources in."
  default     = "us-west-2"
}

/************ ECR Vars ****************/
variable "account_id" {
  type    = string
  default = "347786937011"
}

variable "image_tag" {
  type    = string
  default = "runtime_spdemo"
}

/************ Non-Sensitive Container Config Vars ****************/
variable "CLIENT_BUILD_PATH" {
  type    = string
  default = "build-bm"
}
variable "FS_BUCKET_NAME" {
  type    = string
  default = "sandbox-bm-dlwb"
}

/************ Secrets ****************/
variable "COOKIE_SECRET" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:347786937011:secret:COOKIE_SECRET-ZA7IFQ"
}
variable "SSO_APP_SETTINGS" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:347786937011:secret:SSO_APP_SETTINGS-cS9VI7"
}
variable "TLS_CERT" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:347786937011:secret:TLS_CERT-O4Xk5e"
}
variable "TLS_KEY" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:347786937011:secret:TLS_KEY-lqbzKB"
}
variable "ATLAS_URL" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:347786937011:secret:ATLAS_URL-HtzRhh"
}
variable "FS_ACCESS_KEY" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:347786937011:secret:FS_ACCESS_KEY-vHWBrb"
}
variable "FS_SECRET_KEY" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:347786937011:secret:FS_SECRET_KEY-cmxvJO"
}

/************ Certificate Manager vars ****************/
variable "CERTIFICATE" {
  type    = string
  default = "arn:aws:acm:us-west-2:347786937011:certificate/57da876b-55cc-423e-97b1-ce352d2aa89d"
}
