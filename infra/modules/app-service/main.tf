# create a web app for the sitefinity app to sit in with a private endpoint

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
    app_settings = {
        "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
        "sf-env:ConnectionStringName" = "defaultConnection"
        "sf-env:ConnectionStringParams:defaultConnection" = "Backend=azure"
    }
    site_config {
    }
    connection_string {
        name  = "defaultConnection"
        type  = "SQLAzure"
        value = var.sql_connectionstring
    }
}

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




















