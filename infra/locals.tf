#Get Subscription ID
data "azurerm_client_config" "current" {}

locals {
    subscription_id = data.azurerm_client_config.current.subscription_id
    adminsqlpassword = var.adminsqlpassword == "" ? var.sql.adminsqlpassword.value : var.adminsqlpassword
}