# Terraform mssql

## Introduction

This module deploys a 

This module is compatible with azurerm v2.x

## Dependancies

Hard:

* Resource Groups
* Keyvault
* VNET-Subnet

Optional (depending on options configured):

* log analytics workspace

## Usage

```terraform
variable "SQL_Server" {
  type = any
}

locals {
  environment = lower(var.env)

  deploydbserver = {
    for x in var.SQL_Server :
    "${x.sqlname}" => x if lookup(x, "deploy", true) != false
  }
}

module "MSSQL" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-mssql.git?ref=v1.2.3"
  
  for_each                                 = local.deploydbserver
  environment                              = local.environment
  group                                    = lower(var.group)
  server                                   = each.value
  subnets                                  = local.subnets
  location                                 = lookup(each.value, "location", "canadacentral")
  subnet_id                                = local.subnets.OZ.id
  active_directory_administrator_object_id = lookup(each.value, "active_directory_administrator_object_id", "null") 
  active_directory_administrator_tenant_id = data.azurerm_client_config.current.tenant_id
  DnsPrivatezoneId                         = azurerm_private_dns_zone.dnsprivatezoneDB.id
  deploy_private_dns_zone_group            = lookup(each.value, "deploy_private_dns_zone_group", "true")
  tags = var.tags
}

```
