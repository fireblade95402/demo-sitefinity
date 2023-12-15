#Get Subscription ID
data "azurerm_client_config" "current" {}

locals {
    subscription_id = data.azurerm_client_config.current.subscription_id
}