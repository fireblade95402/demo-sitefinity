# Create Azure Application Gateway a

#create public ip address for the application gateway
resource "azurerm_public_ip" "publicip" {
  name                = "${var.naming["public-ip-address"]}-${var.appgw.name}"
  resource_group_name = "${var.resource-groups[var.appgw.resource_group_key].name}"
  location            = var.location
  allocation_method   = var.appgw.public_ip_address.allocation_method
  sku                 = var.appgw.public_ip_address.sku
}

# get exists subnet id
data "azurerm_subnet" "subnets" {
  for_each = var.networking.vnet.subnets
  name                 = each.value.name
  virtual_network_name = "${var.naming["virtual-network"]}-${var.networking.vnet.name}"
  resource_group_name  = "${var.resource-groups[var.networking.vnet.resource_group_key].name}"
}

#get user assigned identity
data "azurerm_user_assigned_identity" "userassignedidentity" {
  name                = var.identity.name
  resource_group_name = var.identity.resource_group_name
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${var.naming["application-gateway"]}-${var.appgw.name}"
  resource_group_name = "${var.resource-groups[var.appgw.resource_group_key].name}"
  location            = var.location
  sku {
    name     = var.appgw.sku.name
    tier     = var.appgw.sku.tier
    capacity = var.appgw.sku.capacity
  }
  gateway_ip_configuration {
    name      = var.appgw.gateway_ip_configuration.name
    subnet_id = data.azurerm_subnet.subnets[var.appgw.gateway_ip_configuration.subnet_key].id
  }
  frontend_port {
    name = var.appgw.frontend_port.name
    port = var.appgw.frontend_port.port
  }
  frontend_ip_configuration {
    name                 = var.appgw.frontend_ip_configuration.name
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
  backend_address_pool {
    name = var.appgw.backend_address_pool.name
    fqdns = ["${var.web-app.name}.azurewebsites.net"]
  }
  backend_http_settings {
    name                  = var.appgw.backend_http_settings.name
    cookie_based_affinity = var.appgw.backend_http_settings.cookie_based_affinity
    port                  = var.appgw.backend_http_settings.port
    protocol              = var.appgw.backend_http_settings.protocol    
    request_timeout       = var.appgw.backend_http_settings.request_timeout
    pick_host_name_from_backend_address = var.appgw.backend_http_settings.pick_host_name_from_backend_address
    
    

  }
  http_listener {
    name                           = var.appgw.http_listener.name
    frontend_ip_configuration_name = var.appgw.http_listener.frontend_ip_configuration_name
    frontend_port_name             = var.appgw.http_listener.frontend_port_name
    protocol                       = var.appgw.http_listener.protocol
  }

  probe {
    name                = var.appgw.probe.name
    path                = var.appgw.probe.path
    protocol            = var.appgw.probe.protocol
    host                = "${var.web-app.name}.azurewebsites.net"
    interval            = var.appgw.probe.interval
    timeout             = var.appgw.probe.timeout
    unhealthy_threshold = var.appgw.probe.unhealthy_threshold
    
  }
  request_routing_rule {
    name                       = var.appgw.request_routing_rule.name
    rule_type                  = var.appgw.request_routing_rule.rule_type
    http_listener_name         = var.appgw.http_listener.name
    backend_address_pool_name  = var.appgw.backend_address_pool.name
    backend_http_settings_name = var.appgw.backend_http_settings.name
    priority = var.appgw.request_routing_rule.priority

  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.userassignedidentity.id
    ]

    
  }
}






