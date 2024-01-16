# create a web app for the sitefinity app to sit in with a private endpoint

# Get VNET
data "azurerm_virtual_network" "vnet" {
  name = var.networking.vnet.name
   resource_group_name  = "${var.resource-groups[var.networking.vnet.resource_group_key].name}"
}

# get exists subnet id
data "azurerm_subnet" "subnets" {
  for_each = var.networking.vnet.subnets
  name                 = each.value.name
  virtual_network_name = "${var.naming["virtual-network"]}-${var.networking.vnet.name}"
  resource_group_name  = "${var.resource-groups[var.networking.vnet.resource_group_key].name}"
}

# create the app service plan
resource "azurerm_app_service_plan" "appserviceplan" {
    name                = "${var.naming["app-service-plan"]}-${var.web-app.name}"
    location            = var.location
    resource_group_name = "${var.resource-groups[var.web-app.resource_group_key].name}"
    kind                = var.web-app.plan.kind
    reserved            = var.web-app.plan.reserved
    dynamic "sku" {
        for_each = [var.web-app.plan.sku]
        content {
            tier = sku.value.tier
            size = sku.value.size
        }  
    }
}

# create the log analytics workspace
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.naming["log-analytics-workspace"]}-${var.web-app.name}"
  location            =  var.location
  resource_group_name = azurerm_app_service_plan.appserviceplan.resource_group_name
  sku                 = var.web-app.log-analytics.sku
  retention_in_days   = var.web-app.log-analytics.retention_in_days
}

# create application insights
resource "azurerm_application_insights" "appinsights" {
    name                = "${var.naming["app-insights"]}-${var.web-app.name}"
    location            = var.location
    resource_group_name = azurerm_app_service_plan.appserviceplan.resource_group_name
    workspace_id        = azurerm_log_analytics_workspace.workspace.id
    application_type    = var.web-app.appinsights.application_type
}

# create the app service with the app service plan and application insights
resource "azurerm_app_service" "appservice" {
    name                = "${var.web-app.name}"
    location            = var.location
    resource_group_name = azurerm_app_service_plan.appserviceplan.resource_group_name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    https_only          = var.web-app.https_only
    client_affinity_enabled = var.web-app.client_affinity_enabled
    # identity {
    #     type = "SystemAssigned"

    # }
    app_settings = {
        "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
        "sf-env:ConnectionStringName" = "defaultConnection"
        "sf-env:ConnectionStringParams:defaultConnection" = "Backend=azure"
        "WEBSITE_DNS_SERVER": "168.63.129.16",
        "WEBSITE_VNET_ROUTE_ALL": "1"
    }
    dynamic "site_config" {
      for_each = [var.web-app.site_config]
        content {
            dotnet_framework_version  = site_config.value.dotnet_framework_version
       }
    }

    connection_string {
        name  = "defaultConnection"
        type  = "SQLAzure"
        value = var.sql_connectionstring
    }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  app_service_id  = azurerm_app_service.appservice.id
  subnet_id       = data.azurerm_subnet.subnets[var.web-app.subnet_key].id
}

#create private endpoint for app service to connect to sql server
resource "azurerm_private_endpoint" "privateendpoint" {
    name                = "${var.naming["private-endpoint"]}-${var.web-app.name}"
    location            = var.location
    resource_group_name = azurerm_app_service_plan.appserviceplan.resource_group_name
    subnet_id           = data.azurerm_subnet.subnets[var.web-app.pep_subnet_key].id
    private_service_connection {
        name                           = "${var.web-app.name}-privateconnection"
        private_connection_resource_id = azurerm_app_service.appservice.id
        subresource_names              = ["sites"]
        is_manual_connection = false
    }
}


# create the private dns zones
resource "azurerm_private_dns_zone" "privatedns" {
    name                = "privatelink.azurewebsites.net"
    resource_group_name =  azurerm_app_service_plan.appserviceplan.resource_group_name
}

# create the private dns zone links
resource "azurerm_private_dns_zone_virtual_network_link" "privatednslink" {
    depends_on = [ azurerm_private_dns_zone.privatedns ]
        name                  = "${azurerm_app_service.appservice.name}-dnslink"
        resource_group_name   = azurerm_app_service_plan.appserviceplan.resource_group_name
        private_dns_zone_name = azurerm_private_dns_zone.privatedns.name
        virtual_network_id    = data.azurerm_virtual_network.vnet.id
        registration_enabled = false
}



# resource "azurerm_app_service_source_control" "deploy" {
#   app_id   = azurerm_app_service.appservice.id
#   repo_url = "https://github.com/fireblade95402/demo-sitefinity/app"
#   branch   = "master"

# }

# # output the app service id, app service plan id and application insights id
# output "appservice_id" {
#     value = azurerm_app_service.appservice.id
# }

# output "appserviceplan_id" {
#     value = azurerm_app_service_plan.appserviceplan.id
# }

# output "appinsights_id" {
#     value = azurerm_application_insights.appinsights.id
# }

output "default_site_hostname" {
    value = azurerm_app_service.appservice.default_site_hostname
}

# output "identity" {
#     value = azurerm_app_service.appservice.identity
#     sensitive = true
# }   



















