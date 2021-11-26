locals {
  deploydbs = {
    for x in var.server.SQL_Database :
    "${x.sqldbname}" => x if lookup(x, "deploy", true) != false
  }
}


resource "azurerm_mssql_server" "mssql" {
  name                          = "${var.environment}-cio-${var.server["sqlname"]}"
  location                      = var.location
  resource_group_name           = var.server["resource_group_name"]
  version                       = var.server["mssql_version"]
  administrator_login           = var.server["administrator_login"]
  administrator_login_password  = var.server["administrator_login_password"]
  public_network_access_enabled = false

  dynamic "azuread_administrator" {
    for_each = var.server["login_username"] == null ? [] : [var.server["login_username"]]
    content {
      login_username = var.server["login_username"]
      tenant_id      = var.active_directory_administrator_tenant_id
      object_id      = var.active_directory_administrator_object_id
    }
  }
}

resource "azurerm_mssql_database" "mssql" {
  for_each       = local.deploydbs
  name           = "${var.environment}-cio-${each.value.sqldbname}"
  server_id      = azurerm_mssql_server.mssql.id
  collation      = each.value.collation
  license_type   = "LicenseIncluded" #each.value.license_type
  max_size_gb    = each.value.max_size_gb
  read_scale     = each.value.read_scale
  sku_name       = each.value.sku_name
  zone_redundant = each.value.zone_redundant

  dynamic "short_term_retention_policy" {
    for_each = each.value.policyretention_days == null ? [] : [each.value.policyretention_days]
    content {
      retention_days = each.value.policyretention_days
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = each.value.week_of_year == null ? [] : [each.value.week_of_year]
    content {
      weekly_retention  = each.value.weekly_retention
      monthly_retention = each.value.monthly_retention
      yearly_retention  = each.value.yearly_retention
      week_of_year      = each.value.week_of_year
    }
  }

  depends_on = [azurerm_mssql_server.mssql]
}

resource "azurerm_mssql_server_extended_auditing_policy" "mssql" {
  server_id                               = azurerm_mssql_server.mssql.id
  storage_endpoint                        = azurerm_storage_account.mssql.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.mssql.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 6
  depends_on                              = [azurerm_mssql_server.mssql, azurerm_storage_account.mssql]
}

resource "azurerm_mssql_server_security_alert_policy" "mssql" {
  resource_group_name        = var.server["resource_group_name"]
  server_name                = azurerm_mssql_server.mssql.name
  state                      = "Enabled"
  storage_endpoint           = azurerm_storage_account.mssql.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.mssql.primary_access_key
  email_account_admins       = true
  disabled_alerts = [
    "Data_Exfiltration"
  ]
  retention_days = 30
  depends_on     = [azurerm_mssql_server.mssql, azurerm_storage_account.mssql]
}

resource "azurerm_private_endpoint" "mssql" {
  name                = "${var.environment}-cio-${var.server["sqlname"]}-pe"
  location            = var.location
  resource_group_name = var.server["resource_group_name"]
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name                 = "${var.server["sqlname"]}privatednszonegroup"
    private_dns_zone_ids = [var.DnsPrivatezoneId]
  }

  private_service_connection {
    name                           = "${var.environment}-cio-${var.server["sqlname"]}-psc"
    private_connection_resource_id = azurerm_mssql_server.mssql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
  depends_on = [azurerm_mssql_server.mssql]
}

# data "azurerm_private_endpoint_connection" "plinkconnection" {
#   name                = "${azurerm_private_endpoint.mssql.name}"
#   resource_group_name = "${azurerm_private_endpoint.mssql.resource_group_name}"

#   depends_on =[azurerm_private_endpoint.mssql]
# }

# resource "azurerm_private_dns_a_record" "private_endpoint_a_record" {
#   name                = "${azurerm_mssql_server.mssql.name}"
#   zone_name           = "privatelink.azuredatabase.net"
#   resource_group_name = "${var.environment}-CIO_VCBOARDROOM_DNS-rg"
#   ttl                 = 300
#   records             = ["${data.azurerm_private_endpoint_connection.plinkconnection.private_service_connection.0.private_ip_address}"]

# }

# output "private_link_endpoint_ip03" {
#   value = "${azurerm_private_endpoint.CIO-vcboardroom-pe.private_service_connection.0.private_ip_address}"
#}