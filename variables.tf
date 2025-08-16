variable "resource_group_name" { type = string default = "sunil-winvm" }
variable "location"            { type = string default = "Spain Central" }
variable "prefix"              { type = string default = "sunwin" }
variable "vm_name"             { type = string default = "sunwinvm" }
variable "admin_username"      { type = string default = "sunil" }

variable "admin_password" {
  description = "Windows admin password (set as sensitive in Terraform Cloud workspace variables)"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  type    = string
  default = "Standard_D4s_v3"   # 4 vCPU, 16 GiB RAM
}

variable "image_publisher" { type = string default = "MicrosoftWindowsServer" }
variable "image_offer"     { type = string default = "WindowsServer" }
variable "image_sku"       { type = string default = "2019-Datacenter" }
variable "image_version"   { type = string default = "latest" }
