# create a storage account to link to the sitefinity app service 


resource "azurerm_storage_account" "storage" {
  name                     = "${var.naming["storage-account"]}"
  resource_group_name      = "${var.resource-groups[var.storage.resource_group_key].name}"
  location                 = var.location
  account_tier             = var.storage.account_tier
  account_replication_type = var.storage.account_replication_type
}

# create a storage container to link to the sitefinity app service
resource "azurerm_storage_container" "storage" {
  for_each = var.storage.containers
    name                  = each.value.name
    storage_account_name  = azurerm_storage_account.storage.name
    container_access_type = each.value.access_type
}















