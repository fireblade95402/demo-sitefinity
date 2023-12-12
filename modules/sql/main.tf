# create a azure sql database for  sitefinity app

# create the sql server
resource "azurerm_sql_server" "sqlserver" {
    name                         = "sitefinity-sqlserver"
    resource_group_name          = var.rg_name
    location                     = var.location
    version                      = "12.0"
    administrator_login          = "sitefinityadmin"
    administrator_login_password = "Password123!"
}

# create the sql database
resource "azurerm_sql_database" "sqldb" {
    name                = "sitefinity-sqldb"
    resource_group_name = var.rg_name
    location            = var.location
    server_name         = azurerm_sql_server.sqlserver.name
    edition             = "Standard"
    collation           = "SQL_Latin1_General_CP1_CI_AS"
    max_size_gb         = 1
}

