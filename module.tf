locals {
  deploydbs = {
    for x in var.server.SQL_Database :
    "${x.sqldbname}" => x if lookup(x, "deploy", true) != false
  }
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(try(var.tags, null), local.module_tag, try(var.server.tags, null))
}


resource "azurerm_mssql_server" "mssql" {
  name                          = "${var.environment}-${var.group}-${var.server.sqlname}"
  location                      = var.location
  resource_group_name           = var.server.resource_group_name
  version                       = var.server.mssql_version
  administrator_login           = var.server.administrator_login
  administrator_login_password  = var.server.administrator_login_password
  public_network_access_enabled = try(var.server.public_network_access_enabled, false)
  connection_policy             = try(var.server.connection_policy, null)
  minimum_tls_version           = try(var.server.minimum_tls_version, null)
  tags                          = local.tags

  dynamic "azuread_administrator" {
    for_each = try(var.server.login_username, null) == null ? [] : [var.server.login_username]
    content {
      login_username = var.server.login_username
      tenant_id      = var.active_directory_administrator_tenant_id
      object_id      = var.active_directory_administrator_object_id
    }
  }

  dynamic "identity" {
    for_each = lookup(var.server, "identity", {}) == {} ? [] : [1]

    content {
      type = var.server.identity.type
    }
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      identity,
    ]
  }
}

resource "azurerm_mssql_firewall_rule" "firewall_rules" {
  for_each = try(var.server.firewall_rules, {})

  name             = each.value.name
  server_id        = azurerm_mssql_server.mssql.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_mssql_database" "mssql" {
  for_each = local.deploydbs

  name                        = "${var.environment}-${var.group}-${each.value.sqldbname}"
  server_id                   = azurerm_mssql_server.mssql.id
  auto_pause_delay_in_minutes = try(each.value.auto_pause_delay_in_minutes, null)
  create_mode                 = try(each.value.create_mode, null)
  creation_source_database_id = try(each.value.creation_source_database_id, null)
  collation                   = try(each.value.collation, null)
  license_type                = try(each.value.license_type, null)
  max_size_gb                 = try(each.value.max_size_gb, null)
  min_capacity                = try(each.value.min_capacity, null)
  restore_point_in_time       = try(each.value.restore_point_in_time, null)
  read_replica_count          = try(each.value.read_replica_count, null)
  read_scale                  = try(each.value.read_scale, null)
  sample_name                 = try(each.value.sample_name, null)
  sku_name                    = try(each.value.sku_name, null)
  storage_account_type        = try(each.value.storage_account_type, null)
  zone_redundant              = try(each.value.zone_redundant, null)
  tags                        = local.tags

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
  # depends_on = [azurerm_mssql_server.mssql]
}

module "mssql_vitrual_network_rules" {
  source = "./modules/azurerm_mssql_virtual_network_rule"
  for_each                             = local.deploydbs
  mssql_virtual_network_rules          = each.value.azurerm_mssql_virtual_network_rule
  server_id                            = azurerm_mssql_server.mssql.id
  subnets                              = var.subnets
}

resource "azurerm_mssql_server_extended_auditing_policy" "mssql" {
  server_id                               = azurerm_mssql_server.mssql.id
  storage_endpoint                        = azurerm_storage_account.mssql.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.mssql.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 6
  # depends_on                              = [azurerm_mssql_server.mssql, azurerm_storage_account.mssql]
}

resource "azurerm_mssql_server_security_alert_policy" "mssql" {
  resource_group_name        = var.server.resource_group_name
  server_name                = azurerm_mssql_server.mssql.name
  state                      = "Enabled"
  storage_endpoint           = azurerm_storage_account.mssql.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.mssql.primary_access_key
  email_account_admins       = true
  disabled_alerts = [
    "Data_Exfiltration"
  ]
  retention_days = 30
  # depends_on     = [azurerm_mssql_server.mssql, azurerm_storage_account.mssql]
}

resource "azurerm_private_endpoint" "mssql" {
  name                = "${var.environment}-${var.group}-${var.server.sqlname}-pe"
  location            = var.location
  resource_group_name = var.server.resource_group_name
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name                 = "${var.server.sqlname}privatednszonegroup"
    private_dns_zone_ids = [var.DnsPrivatezoneId]
  }

  private_service_connection {
    name                           = "${var.environment}-${var.group}-${var.server.sqlname}-psc"
    private_connection_resource_id = azurerm_mssql_server.mssql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
  # depends_on = [azurerm_mssql_server.mssql]
}
