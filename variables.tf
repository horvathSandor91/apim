variable "resource_group_name" {}
variable "location" {}
variable "application_gateway_name" {}
variable "kv_name" {}
variable "saq_name" {}
variable "subnet_name" {}
variable "nsg_name" {}
variable "sh_pip" {}
variable "appgtw" {}
variable "sh_apim" {}
variable "sh_sc" {}
variable "sh_blob" {}
variable "prefix" {
  type = string
}

variable "postfix" {
  type = string
}
