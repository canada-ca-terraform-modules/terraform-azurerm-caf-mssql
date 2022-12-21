variable "mssql_virtual_network_rules" {
  description = "mssql_virtual_network_rules"
  type = any
}

variable "server_id" {
  type = string
}

variable "subnets" {
  type = any
}

resource "azurerm_mssql_virtual_network_rule" "mssql_virtual_network_rule" {
  for_each                             = var.mssql_virtual_network_rules
  ignore_missing_vnet_service_endpoint = each.value.ignore_missing_vnet_service_endpoint
  name                                 = each.key
  server_id                            = var.server_id
  subnet_id                            = var.subnets[each.value.subnet].id
}