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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 2.75.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 2.75.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_mssql_database.mssql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_firewall_rule.firewall_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_server.mssql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.mssql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [azurerm_mssql_server_security_alert_policy.mssql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_security_alert_policy) | resource |
| [azurerm_private_endpoint.mssql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_storage_account.mssql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_DnsPrivatezoneId"></a> [DnsPrivatezoneId](#input\_DnsPrivatezoneId) | n/a | `any` | n/a | yes |
| <a name="input_active_directory_administrator_object_id"></a> [active\_directory\_administrator\_object\_id](#input\_active\_directory\_administrator\_object\_id) | The Active Directory Administrator Object ID | `string` | `""` | no |
| <a name="input_active_directory_administrator_tenant_id"></a> [active\_directory\_administrator\_tenant\_id](#input\_active\_directory\_administrator\_tenant\_id) | The Active Directory Administrator Tenant ID | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | n/a | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists | `string` | `"canadacentral"` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `""` | no |
| <a name="input_server"></a> [server](#input\_server) | The name of the MSSQL Server | `any` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet that the MSSQL server will be connected to | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mssql_server"></a> [mssql\_server](#output\_mssql\_server) | n/a |
