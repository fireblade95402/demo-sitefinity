
# get keyvault id
data "azurerm_key_vault" "keyvault" {
    name                = var.keyvault.name
    resource_group_name = "${var.resource-groups[var.keyvault.resource_group_key].name}"
}

data "azurerm_client_config" "current" {}


#create user assigned managed identity
resource "azurerm_user_assigned_identity" "userassignedidentity" {
  name                = var.identity.name
  resource_group_name = "${var.resource-groups[var.identity.resource_group_key].name}"
  location = var.location
}

#grant the identity access to the keyvault with get and list permissions for certificates
resource "azurerm_key_vault_access_policy" "keyvaultaccesspolicy" {
  key_vault_id = data.azurerm_key_vault.keyvault.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.userassignedidentity.principal_id
  certificate_permissions = [
    "Get", "List"
  ]
  secret_permissions = [
    "Get", "List"
  ]
}



