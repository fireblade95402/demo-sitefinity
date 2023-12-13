# create a storage account to link to the sitefinity app service 

#generate a random string for the storage account name
resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
  }


resource "azurerm_storage_account" "storage" {
  name                     = "st${random_string.random.result}sitefinity"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# output the storage account name
output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

# output the storage account key
output "storage_account_key" {
  value = azurerm_storage_account.storage.primary_access_key
}














