
data "azurerm_client_config" "current" {}

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

resource "azurerm_key_vault" "keyvault" {
  name                            = var.keyvault.name
  location                        = var.location
  resource_group_name             = var.resource-groups[var.keyvault.resource_group_key].name
  sku_name                        = var.keyvault.sku_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = var.keyvault.soft_delete_retention_days
  purge_protection_enabled        = var.keyvault.purge_protection_enabled
  enabled_for_disk_encryption     = var.keyvault.enabled_for_disk_encryption
  enabled_for_deployment          = var.keyvault.enabled_for_deployment
  enabled_for_template_deployment = var.keyvault.enabled_for_template_deployment
  public_network_access_enabled   = var.keyvault.public_network_access_enabled

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List"
    ]

    certificate_permissions = [
      "Get", "List"
    ]
  }
}


# create the private dns zones
resource "azurerm_private_dns_zone" "privatedns" {
    name                = "privatelink.vaultcore.azure.net"
    resource_group_name =  azurerm_key_vault.keyvault.resource_group_name
}

# create the private dns zone links
resource "azurerm_private_dns_zone_virtual_network_link" "privatednslink" {
    depends_on = [ azurerm_private_dns_zone.privatedns ]
        name                  = "${azurerm_key_vault.keyvault.name}-dnslink"
        resource_group_name   = azurerm_key_vault.keyvault.resource_group_name
        private_dns_zone_name = azurerm_private_dns_zone.privatedns.name
        virtual_network_id    = data.azurerm_virtual_network.vnet.id
        registration_enabled = false
}

#create private endpoint for keyvault service to connect to sql server
resource "azurerm_private_endpoint" "privateendpoint" {
    name                = "${var.naming["private-endpoint"]}-${var.keyvault.name}"
    location            = var.location
    resource_group_name = azurerm_key_vault.keyvault.resource_group_name
    subnet_id           = data.azurerm_subnet.subnets[var.keyvault.pep_subnet_key].id

    private_dns_zone_group {
    name = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatedns.id]
    }

    private_service_connection {
        name                           = "${var.keyvault.name}-privateconnection"
        private_connection_resource_id = azurerm_key_vault.keyvault.id
        subresource_names              = ["vault"]
        is_manual_connection = false
    }
}
