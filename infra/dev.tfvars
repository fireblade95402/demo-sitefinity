environment = "dev"
location    = "uksouth"

// Reference existing keyvault
keyvault = {
  name = "mykeyvaultmwg"
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
        name           = "frontendSubnet"
        address_prefix = ["10.0.1.0/24"]
      },
      backend = {
        name           = "backendSubnet"
        address_prefix = ["10.0.2.0/24"]
      }
    }
    # private_dns_zones = {
    #   web-app = {
    #     name   = "web-app.local"
    #     domain = "privatelink.azurewebsites.net"
    #   },
    #   sql = {
    #     name   = "sql.local"
    #     domain = "privatelink.database.windows.net"
    #   }

    # }
  }
}

web-app = {
  name               = "sitefinity2-mwg"
  resource_group_key = "sitefinity"
  https_only         = true
  client_affinity_enabled = true
  plan = {
    kind = "Windows"
    reserved = false
    sku = {
      tier = "Standard"
      size = "S1"
    }
  }
  log-analytics = {
    sku = "PerGB2018"
    retention_in_days = 30
  }
  appinsights = {
    application_type = "web"
  }
}

sql = {
    name               = "sitefinity-mwg"
    resource_group_key = "sitefinity"
    version            = "12.0"
    admin_login_kv_secret_name = "adminsqllogin"
    admin_pwd_kv_secret_name = "adminsqlpwd"
    database = {
      name = "sitefinity"
      collation = "SQL_Latin1_General_CP1_CI_AS"
      edition = "Standard"
      max_size_gb = 1
    }
}

storage = {
  name               = "sitefinitymwg"
  resource_group_key = "sitefinity"
  account_tier       = "Standard"
  account_replication_type = "LRS"
  containers = {
    logs = {
      name = "logs"
      access_type = "private"
    }
    backups = {
      name = "backups"
      access_type = "private"
    }
  }
}

redis = {
    name               = "sitefinity-mwg"
    resource_group_key = "sitefinity"
    sku = {
        name = "Standard"
        family = "C"
        capacity = 1
    }
    enable_non_ssl_port = false
    minimum_tls_version = "1.2"
    subnet_id = "frontendSubnet"
}

appgw = {
    name               = "sitefinity-mwg"
    resource_group_key = "sitefinity"
    sku = {
        name = "Standard_v2"
        tier = "Standard_v2"
        capacity = 1
    }
    gateway_ip_config = {
        name = "sitefinity-mwg"
        subnet_key = "frontend"
    }
    frontend_port = {
        name = "sitefinity-mwg"
        port = 80
    }
    frontend_ip_config = {
        name = "sitefinity-mwg"
        private_ip_address_allocation = "Dynamic"
        subnet_key = "frontend"
    }
    backend_address_pool = {
        name = "sitefinity-mwg"
    }
    backend_http_settings = {
        name = "sitefinity-mwg"
        cookie_based_affinity = "Disabled"
        port = 80
        protocol = "Http"
        request_timeout = 20
        path = "/"
    }
    http_listener = {
        name = "sitefinity-mwg"
        frontend_port_name = "sitefinity-mwg"
        frontend_ip_configuration_name = "sitefinity-mwg"
        ssl_certificate_name = "sitefinity-mwg"
        require_server_name_indication = true
        protocol = "Http"
    }
    request_routing_rule = {
        name = "sitefinity-mwg"
        rule_type = "Basic"
        http_listener_name = "sitefinity-mwg"
        backend_address_pool_name = "sitefinity-mwg"
        backend_http_settings_name = "sitefinity-mwg"
    }
    public_ip_address = {
        name = "sitefinity-mwg"
        sku = "Standard"
        allocation_method = "Static"
    }
}




