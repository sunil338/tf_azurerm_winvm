variable "resource_group_name" { default = "sunil-winvm" }
variable "location"            { default = "Spain Central" }
variable "prefix"              { default = "sunwin" }
variable "vm_name"             { default = "sunwinvm" }
variable "admin_username"      { default = "sunil" }

variable "admin_password" {
  description = "Windows admin password (set as sensitive in Terraform Cloud workspace variables)"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  type    = string
  default = "Standard_D4s_v3"   # 4 vCPU, 16 GiB RAM
}

variable "image_publisher" { default = "MicrosoftWindowsServer" }
variable "image_offer"     { default = "WindowsServer" }
variable "image_sku"       { default = "2019-Datacenter" }
variable "image_version"   { default = "latest" }
