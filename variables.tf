/************ Tags ****************/
variable "tags" {
  type        = map(string)
  description = "The default tags to apply to all resources."
  default = {
    Owner       = "csplearnings@gmail.com"
    Project     = "DLWB-BM"
    Environment = "Sandbox"
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
  default = "868686364197"
}

variable "image_tag" {
  type    = string
  default = "runtime_v2"
}

/************ Non-Sensitive Container Config Vars ****************/
variable "CLIENT_BUILD_PATH" {
  type    = string
  default = "build-bm"
}
variable "FS_BUCKET_NAME" {
  type    = string
  default = "dev-dlwb"
}

/************ Secrets ****************/
variable "COOKIE_SECRET" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:868686364197:secret:cookie_secret-qa0Vxr"
}
variable "SSO_APP_SETTINGS" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-1:347786937011:secret:SSO_APP_SETTINGS-AoAUIO"
}
variable "TLS_CERT" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:868686364197:secret:ssl.crt-d3S0d2"
}
variable "TLS_KEY" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:868686364197:secret:ssl.key-s0xvD9"
}
variable "ATLAS_URL" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:868686364197:secret:ATLAS_URL-coIoeA"
}
variable "FS_ACCESS_KEY" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:868686364197:secret:FS_ACCESS_KEY-uMtW6g"
}
variable "FS_SECRET_KEY" {
  type    = string
  default = "arn:aws:secretsmanager:us-west-2:868686364197:secret:FS_SECRET_KEY-HmiEbi"
}

/************ Certificate Manager vars ****************/
variable "CERTIFICATE" {
  type    = string
  default = "arn:aws:acm:us-west-2:868686364197:certificate/dc2b8f8a-9edc-4c6c-831e-6488516b9331"
}
