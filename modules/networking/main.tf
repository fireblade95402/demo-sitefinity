# create a vnet for the sitefinity app to sit in with front and back end subnets
# include a private dns zone for the vnet for the sitefinity app to use

# create the vnet
resource "azurerm_virtual_network" "vnet" {
    name                = "sitefinity-vnet"
    address_space       = ["10.1.0.0/16"]
    location            = var.location
    resource_group_name = var.rg_name
}

# create the front end subnet
resource "azurerm_subnet" "frontend-subnet" {
    name                 = "frontend-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.1.0.0/24"]
}

# create the back end subnet
resource "azurerm_subnet" "backend-subnet" {
    name                 = "backend-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.1.1.0/24"]
}

# create the private dns zone
resource "azurerm_private_dns_zone" "privatedns-webapp" {
    name                = "privatelink.azurewebsites.net"
    resource_group_name = var.rg_name
}

# create the private dns zone link
resource "azurerm_private_dns_zone_virtual_network_link" "privatednslink" {
    name                  = "privatelink.azurewebsites.net"
    resource_group_name   = var.rg_name
    private_dns_zone_name = azurerm_private_dns_zone.privatedns-webapp.name
    virtual_network_id    = azurerm_virtual_network.vnet.id
}

# create the private dns zone for sql server
resource "azurerm_private_dns_zone" "privatedns-sql" {
    name                = "privatelink.database.windows.net"
    resource_group_name = var.rg_name
}

# create the private dns zone link for sql server
resource "azurerm_private_dns_zone_virtual_network_link" "privatednslink-sql" {
    name                  = "privatelink.database.windows.net"
    resource_group_name   = var.rg_name
    private_dns_zone_name = azurerm_private_dns_zone.privatedns-sql.name
    virtual_network_id    = azurerm_virtual_network.vnet.id
}


# output the vnet id, front end subnet id, private dns zone id and private dns zone link id
output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

output "frontend_subnet_id" {
    value = azurerm_subnet.frontend-subnet.id
}

output "backend_subnet_id" {
    value = azurerm_subnet.backend-subnet.id
}

output "privatedns-webapp_id" {
    value = azurerm_private_dns_zone.privatedns-webapp.id
}

output "privatedns-sql_id" {
    value = azurerm_private_dns_zone.privatedns-sql.id
}






