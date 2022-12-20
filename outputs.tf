# output "id" {
#   value = azurerm_mssql_server.mssql.id
# }

# output "name" {
#   value = azurerm_mssql_server.mssql.name
# }

# output "administrator_login" {
#   value = azurerm_mssql_server.mssql.administrator_login
# }

output "server" {
  value = var.server
}

# output "mssql_databases" {
#   value = azurerm_mssql_database.mssql
# }

# Part of a hack for module-to-module dependencies.
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
# and
# https://github.com/hashicorp/terraform/issues/1178#issuecomment-473091030
# output "depended_on" {
#   value = "${null_resource.dependency_setter.id}-${timestamp()}"
# }