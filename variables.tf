variable "tags" {
  type    = any
  default = null
}

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

variable "subnets" {
  description = "Subnets withing the VNETs"
}

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

variable "deploy_private_dns_zone_group" {
  description = ""
  default     = true
  type        = bool
}
