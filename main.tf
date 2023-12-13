

#Generic Naming module from CCoE
module "names" {
  source   = "./modules/naming"
  env      = var.environment
  location = var.location
  subId    = local.subscription_id
}

#Resource Group Creation
resource "azurerm_resource_group" "rg" {
  for_each = var.resource-groups 
    name     = "${module.names.standard["resource-group"]}-${each.value.name}"
    location = var.location
}


# Call the networking module
module "networking" {
    depends_on = [ azurerm_resource_group.rg ]
    source = "./modules/networking"
    location = var.location
    resource-groups = var.resource-groups
    networking = var.networking
    naming = module.names.standard
}

# Call the app service module
module "app-service" {
    source = "./modules/app-service"
    location = var.location
    resource-groups = var.resource-groups
    web-app = var.web-app
    naming = module.names.standard
}

# Call the sql module
module "sql" {
    source = "./modules/sql"
    location = var.location
    resource-groups = var.resource-groups
    sql =var.sql 
    naming = module.names.standard   
}

# Call the storage module
module "storage" {
    source = "./modules/storage"
    location = var.location
    resource-groups = var.resource-groups
    storage =var.storage 
    naming = module.names.standard 
}

# Call the redis module
module "redis" {
    source = "./modules/redis"
    location = var.location
    resource-groups = var.resource-groups
    redis =var.redis 
    naming = module.names.standard 
}

# Call the appgw module
module "appgw" {
    source = "./modules/appgw"
    location = var.location
    resource-groups = var.resource-groups
    appgw =var.appgw 
    naming = module.names.standard 
}



