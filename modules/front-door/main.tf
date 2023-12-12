# create azure front door for sitefinity app with a firewall policy and private link integration

# create the front door profile
resource "azurerm_cdn_frontdoor_profile" "frontdoor" {
  name                = "sitefinity-frontdoor"
  resource_group_name = var.rg_name
  sku_name            = "Premium_AzureFrontDoor"
}

# create the front door endpoint
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "sitefinity-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
}

# create the front door origin group
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "sitefinity-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontdoor.id
  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }
  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

# 
resource "azurerm_cdn_frontdoor_origin" "origin" {
    name                     = "sitefinity-origin"
    cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
    host_name                = var.default_site_hostname
    http_port                = 80
    https_port               = 443
    priority                 = 1
    weight                   = 1000
    origin_host_header       = var.default_site_hostname
    certificate_name_check_enabled = true
    enabled = true

}

resource "azurerm_cdn_frontdoor_route" "route" {
    name = "sitefinity-route"
    cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.endpoint.id
    cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
    cdn_frontdoor_origin_ids = [azurerm_cdn_frontdoor_origin.origin.id]
    supported_protocols = ["Http", "Https"]
    forwarding_protocol = "HttpsOnly"
    patterns_to_match = ["/*"]
}