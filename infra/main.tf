
#Generic Naming module from CCoE
module "names" {
  source   = "./modules/naming"
  env      = var.environment
  location = var.location
  subId    = local.subscription_id
}

# #Resource Group Creation
# resource "azurerm_resource_group" "rg" {
#   for_each = var.resource-groups 
#     name     = "${each.value.name}"
#     location = var.location
# }



# Call the networking module
module "networking" {
    source = "./modules/networking"
    location = var.location
    resource-groups = var.resource-groups
    networking = var.networking
    naming = module.names.standard
}

# Call the app service module
module "app-service" {
    depends_on = [ module.networking, module.sql ]
    source = "./modules/app-service"
    location = var.location
    resource-groups = var.resource-groups
    web-app = var.web-app
    networking = var.networking
    sql_connectionstring = module.sql.sql_connectionstring
    naming = module.names.standard
}

# Call the sql module
module "sql" {
    depends_on = [ module.networking ]
    source = "./modules/sql"
    location = var.location
    resource-groups = var.resource-groups
    sql =var.sql
    keyvault = var.keyvault 
    naming = module.names.standard   
}

# Call the storage module
# module "storage" {
#     depends_on = [ module.networking ]
#     source = "./modules/storage"
#     location = var.location
#     resource-groups = var.resource-groups
#     storage =var.storage 
#     naming = module.names.standard 
# }

# Call the redis module
# module "redis" {
#     depends_on = [ module.networking ]
#     source = "./modules/redis"
#     location = var.location
#     resource-groups = var.resource-groups
#     redis =var.redis 
#     naming = module.names.standard 
# }


# Call the appgw module -tbc
# module "appgw" {
#     source = "./modules/appgw"
#     location = var.location
#     resource-groups = var.resource-groups
#     appgw =var.appgw 
#     networking = var.networking
#     naming = module.names.standard 
# }



