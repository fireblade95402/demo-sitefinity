# create a web app for the sitefinity app to sit in with a private endpoint

# create the app service plan
resource "azurerm_app_service_plan" "appserviceplan" {
    name                = "sitefinity-appserviceplan"
    location            = var.location
    resource_group_name = var.rg_name
    kind                = "Linux"
    reserved            = true

    sku {
        tier = "Standard"
        size = "S1"
    }
}

# create the log analytics workspace
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "sitefinity-workspace"
  location            =  var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# create application insights
resource "azurerm_application_insights" "appinsights" {
    name                = "sitefinity-appinsights"
    location            = var.location
    resource_group_name = var.rg_name
    workspace_id        = azurerm_log_analytics_workspace.workspace.id
    application_type    = "web"
}

# create the app service with the app service plan and application insights
resource "azurerm_app_service" "appservice" {
    name                = "sitefinity-appservice"
    location            = var.location
    resource_group_name = var.rg_name
    app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
    https_only          = true
    client_affinity_enabled = false
    app_settings = {
        "WEBSITE_RUN_FROM_PACKAGE" = "https://sitefinity.blob.core.windows.net/sitefinity/sitefinity.zip"
        "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
    }
    site_config {
        linux_fx_version = "DOCKER|telerik/sitefinity:latest"
        always_on = true
    }
}

# output the app service id, app service plan id and application insights id
output "appservice_id" {
    value = azurerm_app_service.appservice.id
}

output "appserviceplan_id" {
    value = azurerm_app_service_plan.appserviceplan.id
}

output "appinsights_id" {
    value = azurerm_application_insights.appinsights.id
}

output "default_site_hostname" {
    value = azurerm_app_service.appservice.default_site_hostname
}




















