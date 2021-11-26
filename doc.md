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
module "MSSQL" {
  source                                   = "github.com/ssc-spc-cloud-nuage/MSSQL_MODULE?ref=v1.1"
  for_each                                 = local.deploydbserver
  environment                              = local.environment
  server                                   = each.value
  location                                 = lookup(each.value, "location", "canadacentral")
  subnet_id                                = local.subnets.RZ.id
  active_directory_administrator_object_id = data.azurerm_client_config.current.object_id
  active_directory_administrator_tenant_id = data.azurerm_client_config.current.tenant_id
  DnsPrivatezoneId                         = azurerm_private_dns_zone.dnsprivatezoneDB.id
}
```
