# create a vnet for the sitefinity app to sit in with front and back end subnets
# include a private dns zone for the vnet for the sitefinity app to use

# create the vnet
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.naming["virtual-network"]}-${var.networking.vnet.name}"
    address_space       = var.networking.vnet.address_space
    location            = var.location
    resource_group_name = "${var.naming["resource-group"]}-${var.resource-groups[var.networking.vnet.resource_group_key].name}"
}

# create the subnets
resource "azurerm_subnet" "subnets" {
    for_each = var.networking.vnet.subnets
        name                 = each.value.name
        resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
        virtual_network_name = azurerm_virtual_network.vnet.name
        address_prefixes     = each.value.address_prefix
}

# create the private dns zones
resource "azurerm_private_dns_zone" "privatedns" {
    for_each = var.networking.vnet.private_dns_zones
    name                = each.value.name
    resource_group_name = azurerm_virtual_network.vnet.resource_group_name
}

# create the private dns zone links
resource "azurerm_private_dns_zone_virtual_network_link" "privatednslink" {
    depends_on = [ azurerm_private_dns_zone.privatedns ]
    for_each = var.networking.vnet.private_dns_zones
        name                  = each.value.domain
        resource_group_name   = azurerm_virtual_network.vnet.resource_group_name
        private_dns_zone_name = each.value.name
        virtual_network_id    = azurerm_virtual_network.vnet.id
}








