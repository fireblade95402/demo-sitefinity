# Create Azure Application Gateway a

#create public ip address for the application gateway
resource "azurerm_public_ip" "publicip" {
  name                = "${var.naming["public-ip-address"]}-${var.appgw.name}"
  resource_group_name = "${var.naming["resource-group"]}-${var.resource-groups[var.appgw.resource_group_key].name}"
  location            = var.location
  allocation_method   = var.appgw.public_ip_address.allocation_method
  sku                 = var.appgw.public_ip_address.sku
}

# get exists subnet id
data "azurerm_subnet" "subnets" {
  for_each = var.networking.vnet.subnets
  name                 = each.value.name
  virtual_network_name = "${var.naming["virtual-network"]}-${var.networking.vnet.name}"
  resource_group_name  = "${var.naming["resource-group"]}-${var.resource-groups[var.networking.vnet.resource_group_key].name}"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.naming["application-gateway"]}-${var.appgw.name}"
  resource_group_name = "${var.naming["resource-group"]}-${var.resource-groups[var.appgw.resource_group_key].name}"
  location            = var.location
  sku {
    name     = var.appgw.sku.name
    tier     = var.appgw.sku.tier
    capacity = var.appgw.sku.capacity
  }
  gateway_ip_configuration {
    name      = var.appgw.gateway_ip_config.name
    subnet_id = data.azurerm_subnet.subnets[var.appgw.gateway_ip_config.subnet_key].id
  }
  frontend_port {
    name = var.appgw.frontend_port.name
    port = var.appgw.frontend_port.port
  }
  frontend_ip_configuration {
    name                 = var.appgw.frontend_ip_config.name
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
  backend_address_pool {
    name = var.appgw.backend_address_pool.name
  }
  backend_http_settings {
    name                  = var.appgw.backend_http_settings.name
    cookie_based_affinity = var.appgw.backend_http_settings.cookie_based_affinity
    path                  = var.appgw.backend_http_settings.path
    port                  = var.appgw.backend_http_settings.port
    protocol              = var.appgw.backend_http_settings.protocol    
    request_timeout       = var.appgw.backend_http_settings.request_timeout
  }
  http_listener {
    name                           = var.appgw.http_listener.name
    frontend_ip_configuration_name = var.appgw.http_listener.name
    frontend_port_name             = var.appgw.http_listener.name
    protocol                       = var.appgw.http_listener.protocol
  }
  request_routing_rule {
    name                       = var.appgw.request_routing_rule.name
    rule_type                  = var.appgw.request_routing_rule.rule_type
    http_listener_name         = var.appgw.http_listener.name
    backend_address_pool_name  = var.appgw.backend_address_pool.name
    backend_http_settings_name = var.appgw.backend_http_settings.name
  }
}






