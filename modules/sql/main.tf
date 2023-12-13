# create a azure sql database for  sitefinity app

# create the sql server
resource "azurerm_sql_server" "sqlserver" {
    name                         = "${var.naming["sql-server"]}-${var.sql.name}"
    resource_group_name          = "${var.naming["resource-group"]}-${var.resource-groups[var.sql.resource_group_key].name}"
    location                     = var.location
    version                      = var.sql.version
    administrator_login          = "sitefinityadmin" #todo - get from keyvault
    administrator_login_password = "Password123!" #todo - get from keyvault
}

# create the sql database
resource "azurerm_sql_database" "sqldb" {
    name                = "${var.sql.database.name}"
    resource_group_name = azurerm_sql_server.sqlserver.resource_group_name
    location            = azurerm_sql_server.sqlserver.location
    server_name         = azurerm_sql_server.sqlserver.name
    edition             = var.sql.database.edition
    collation           = var.sql.database.collation
    max_size_gb         = var.sql.database.max_size_gb
}

