environment = "dev"
location    = "uksouth"

// Reference existing keyvault
keyvault = {
  name                = "myvault-mwg"
  resource_group_name = "Shared"
}

// User assigned identity
identity = {
  name                = "sitefinity-managed-identity"
  resource_group_name = "Shared"
}


resource-groups = {
  sitefinity = {
    name = "demo-sitefinity"
  }
}

networking = {
  vnet = {
    name               = "sitefinity-vnet"
    resource_group_key = "sitefinity"
    address_space      = ["10.0.0.0/16"]
    subnets = {
      frontend = {
        name           = "appServiceSubnet"
        address_prefix = ["10.0.1.0/24"]
        delegation = {
          name = "Microsoft.Web/serverFarms"
          service_delegation = {
            name    = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      },
      backend = {
        name           = "backendSubnet"
        address_prefix = ["10.0.2.0/24"]
      },
      integration = {
        name           = "privateEndpointSubnet"
        address_prefix = ["10.0.3.0/24"]
      },
      appgw = {
        name           = "appGWSubnet"
        address_prefix = ["10.0.4.0/24"]
      }
    }
    private_dns_zones = {
      web-app = {
        name   = "privatelink.azurewebsites.net"
        domain = "privatelink.azurewebsites.net"
      }
      sql = {
        name   = "privatelink.database.windows.net"
        domain = "privatelink.database.windows.net"
      }

    }
  }
}

web-app = {
  name                    = "sitefinity-mcaps"
  resource_group_key      = "sitefinity"
  https_only              = true
  client_affinity_enabled = true
  plan = {
    kind     = "Windows"
    reserved = false
    sku = {
      tier = "Standard"
      size = "S1"
    }
  }
  subnet_key     = "frontend"
  pep_subnet_key = "integration"
  site_config = {
    dotnet_framework_version = "v4.0"
  }
  log-analytics = {
    sku               = "PerGB2018"
    retention_in_days = 30
  }
  appinsights = {
    application_type = "web"
  }
}

sql = {
  name                       = "sitefinity-private"
  resource_group_key         = "sitefinity"
  version                    = "12.0"
  pep_subnet_key             = "integration"
  database = {
    name        = "sitefinity"
    collation   = "SQL_Latin1_General_CP1_CI_AS"
    edition     = "Standard"
    max_size_gb = 1
  }
}

storage = {
  name                     = "sitefinitymwg"
  resource_group_key       = "sitefinity"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  containers = {
    logs = {
      name        = "logs"
      access_type = "private"
    }
    backups = {
      name        = "backups"
      access_type = "private"
    }
  }
}

redis = {
  name               = "sitefinity-mwg"
  resource_group_key = "sitefinity"
  sku = {
    name     = "Standard"
    family   = "C"
    capacity = 1
  }
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  subnet_id           = "frontendSubnet"
}

appgw = {
  name               = "sitefinity-mwg"
  resource_group_key = "sitefinity"
  sku = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }
  gateway_ip_configuration  = {
    name       = "sitefinity-mwg"
    subnet_key = "appgw"
  }
  frontend_port = {
    name = "http"
    port = 80
  }
  frontend_ip_configuration  = {
    name                          = "frontend"
    private_ip_address_allocation = "Dynamic"
    subnet_key                    = "frontend"
  }
  backend_address_pool = {
    name = "AppService"
  }
  backend_http_settings = {
    name                  = "https"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
    probe_name            = "probe"
    pick_host_name_from_backend_address = true
  }

  probe = {
    name                = "probe"
    protocol            = "Http"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  listener = {
    http_listener = {
      name                           = "http"
      frontend_ip_configuration_name = "frontend"
      frontend_port_name             = "http"
      protocol                       = "Http"
    },
    https_listener = {
      name                           = "https"
      frontend_ip_configuration_name = "frontend"
      frontend_port_name             = "https"
      protocol                       = "Https"
      ssl_certificate_name           = "sitefinity-mwg"
    }
  }


  request_routing_rule = {
    name                       = "http"
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = "AppService"
    backend_http_settings_name = "http"
    priority                   = 1
  }
  public_ip_address = {
    name              = "sitefinity-mwg"
    sku               = "Standard"
    allocation_method = "Static"
  }

  ssl_certificate = {
    name     = "sitefinity-mwg"
    keyvault_cert_id = "https://myvault-mwg.vault.azure.net/secrets/sitefinity/6108c6398f9a407bb0f7ba24e3f2d2f1"

  }
}




