variable "environment" {
  description = ""
}

variable "group" {
  default = ""
}

variable "project" {
  default = ""
}

variable "location" {
  description = "Specifies the supported Azure location where the resource exists"
  default     = "canadacentral"
}

variable "server" {
  description = "The name of the MSSQL Server"
  type        = any
}

variable "subnet_id" {
  description = "The ID of the subnet that the MSSQL server will be connected to"
}

# variable "subnet_id_EP" {
#   description = "The ID of the subnet that the Apps Service server will be connected to"
# }

variable "active_directory_administrator_object_id" {
  description = "The Active Directory Administrator Object ID"
  default     = ""
}

variable "active_directory_administrator_tenant_id" {
  description = "The Active Directory Administrator Tenant ID"
  default     = ""
}

variable "DnsPrivatezoneId" {
  description = ""
}