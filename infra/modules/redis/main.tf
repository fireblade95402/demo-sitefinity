# create a azure redis cache for sitefinity app

# create the redis cache
resource "azurerm_redis_cache" "redis" {
  name                = "${var.naming["redis"]}-${var.redis.name}"
  resource_group_name = "${var.resource-groups[var.redis.resource_group_key].name}"
  location            = var.location
  capacity            = var.redis.sku.capacity
  family              = var.redis.sku.family
  sku_name            = var.redis.sku.name
  enable_non_ssl_port = var.redis.enable_non_ssl_port
  minimum_tls_version = var.redis.minimum_tls_version

  redis_configuration {
  }
}






