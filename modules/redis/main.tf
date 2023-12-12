# create a azure redis cache for sitefinity app

# create the redis cache
resource "azurerm_redis_cache" "redis" {
  name                = "sitefinity-redis"
  resource_group_name = var.rg_name
  location            = var.location
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

# output the redis cache id
output "redis_id" {
  value = azurerm_redis_cache.redis.id
}




