
//add the provider
provider "azurerm" {
    features {}
}

//create the variables
variable "rg_name" {
    type = string
    default = "demo-sitefinity"
}

variable "location" {
    type = string
    default = "uksouth"
}

//create resource group taking in the variables
resource "azurerm_resource_group" "rg" {
    name     = var.rg_name
    location = var.location
}


# Call the networking module
module "networking" {
    source = "./modules/networking"
    rg_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}

# Call the app service module
module "app-service" {
    source = "./modules/app-service"
    rg_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}

# Call the sql module
module "sql" {
    source = "./modules/sql"
    rg_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}

# Call the redis module
module "redis" {
    source = "./modules/redis"
    rg_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}

# Call Front Door module
module "front-door" {
    source = "./modules/front-door"
    rg_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    default_site_hostname = module.app-service.default_site_hostname
}

# Call the storage module
module "storage" {
    source = "./modules/storage"
    rg_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}

