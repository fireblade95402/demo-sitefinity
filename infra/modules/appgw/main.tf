# Create Azure Application Gateway a

#create public ip address for the application gateway
resource "azurerm_public_ip" "publicip" {
  name                = "${var.naming["public-ip-address"]}-${var.appgw.name}"
  resource_group_name = "${var.resource-groups[var.appgw.resource_group_key].name}"
  location            = var.location
  allocation_method   = var.appgw.public_ip_address.allocation_method
  sku                 = var.appgw.public_ip_address.sku
  domain_name_label = var.appgw.public_ip_address.domain_name_label
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

  dynamic "frontend_port" {
    for_each = var.appgw.frontend_port
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
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
  dynamic "http_listener" {
        for_each = var.appgw.listener
        content {
          name                            = http_listener.value.name
          frontend_ip_configuration_name  = http_listener.value.frontend_ip_configuration_name
          frontend_port_name              = http_listener.value.frontend_port_name
          protocol                        = http_listener.value.protocol
          ssl_certificate_name            = lookup(http_listener.value, "ssl_certificate_name", null)
        }
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
  dynamic "request_routing_rule" {
    for_each = var.appgw.request_routing_rule
    content {
    name                       = request_routing_rule.value.name
    rule_type                  = request_routing_rule.value.rule_type
    http_listener_name         = request_routing_rule.value.http_listener_name
    backend_address_pool_name  = lookup(request_routing_rule.value, "backend_address_pool_name", null)
    backend_http_settings_name = lookup(request_routing_rule.value, "backend_http_settings_name", null)
    priority = request_routing_rule.value.priority
    redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
  
    
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.appgw.redirect_configuration
    content {
      name = redirect_configuration.value.name
      redirect_type = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_name
      include_path = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string

    }
    
  }



  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.userassignedidentity.id
    ]

    
  }

  ## add ssl certificate from keyvault with keyvault id
  ssl_certificate {
    name     = var.appgw.ssl_certificate.name
    key_vault_secret_id = var.appgw.ssl_certificate.keyvault_cert_id

  }
}






