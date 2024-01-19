# create a azure sql database for  sitefinity app

# get keyvault id
data "azurerm_key_vault" "keyvault" {
    name                = var.keyvault.name
    resource_group_name = "${var.resource-groups[var.keyvault.resource_group_key].name}"
}

# get the sql admin password from keyvault
data "azurerm_key_vault_secret" "adminsqllogin" {
    name         = "adminsqllogin"
    key_vault_id = data.azurerm_key_vault.keyvault.id
}
data "azurerm_key_vault_secret" "adminsqlpwd" {
    name         = "adminsqlpassword"
    key_vault_id = data.azurerm_key_vault.keyvault.id
}

# Get VNET
data "azurerm_virtual_network" "vnet" {
  name = "${var.naming["virtual-network"]}-${var.networking.vnet.name}"
  resource_group_name  = "${var.resource-groups[var.networking.vnet.resource_group_key].name}"
}

# get exists subnet id
data "azurerm_subnet" "subnets" {
  for_each = var.networking.vnet.subnets
  name                 = each.value.name
  virtual_network_name = "${var.naming["virtual-network"]}-${var.networking.vnet.name}"
  resource_group_name  = "${var.resource-groups[var.networking.vnet.resource_group_key].name}"
}

# create the sql server
resource "azurerm_mssql_server" "sqlserver" {
    name                         = "${var.naming["sql-server"]}-${var.sql.name}"
    resource_group_name          = "${var.resource-groups[var.sql.resource_group_key].name}"
    location                     = var.location
    version                      = var.sql.version
    # use an entra user for the administator login
    administrator_login          = data.azurerm_key_vault_secret.adminsqllogin.value
    administrator_login_password = data.azurerm_key_vault_secret.adminsqlpwd.value
}

# # create the firewall rule for sql server
# resource "azurerm_sql_firewall_rule" "sqlfirewall" {
#     name                = "AllowAllWindowsAzureIps"
#     resource_group_name = azurerm_mssql_server.sqlserver.resource_group_name
#     server_name         = azurerm_mssql_server.sqlserver.name
#     start_ip_address    = "0.0.0.0"
#     end_ip_address      = "0.0.0.0"
#     depends_on = [ azurerm_sql_database.sqldb ]
# }


# create the private dns zones
resource "azurerm_private_dns_zone" "privatedns" {
    name                = "privatelink.database.windows.net"
    resource_group_name =  azurerm_mssql_server.sqlserver.resource_group_name
}

# create the private dns zone links
resource "azurerm_private_dns_zone_virtual_network_link" "privatednslink" {
    depends_on = [ azurerm_private_dns_zone.privatedns ]
        name                  = "${azurerm_mssql_server.sqlserver.name}-dnslink"
        resource_group_name   = azurerm_mssql_server.sqlserver.resource_group_name
        private_dns_zone_name = azurerm_private_dns_zone.privatedns.name
        virtual_network_id    = data.azurerm_virtual_network.vnet.id
        registration_enabled = false
}

#create private endpoint for app service to connect to sql server
resource "azurerm_private_endpoint" "privateendpoint" {
    name                = "${var.naming["private-endpoint"]}-${var.sql.name}"
    location            = var.location
    resource_group_name = azurerm_mssql_server.sqlserver.resource_group_name
    subnet_id           = data.azurerm_subnet.subnets[var.sql.pep_subnet_key].id

    private_dns_zone_group {
    name = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatedns.id]
    }

    private_service_connection {
        name                           = "${var.sql.name}-privateconnection"
        private_connection_resource_id = azurerm_mssql_server.sqlserver.id
        subresource_names              = ["sqlServer"]
        is_manual_connection = false
    }
}

# create the sql database
resource "azurerm_mssql_database" "sqldb" {
    name                = "${var.sql.database.name}"
    server_id         = azurerm_mssql_server.sqlserver.id
    collation           = var.sql.database.collation
    max_size_gb         = var.sql.database.max_size_gb
}


# output connectionstring for sql database to be used in app service
output "sql_connectionstring" {
    value = "Server=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqldb.name};Persist Security Info=False;User ID=${data.azurerm_key_vault_secret.adminsqllogin.value};Password=${data.azurerm_key_vault_secret.adminsqlpwd.value};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    sensitive = true
}

