variable "environment" {
  description = "(Required) Environment Postfix for naming on resources"  
}

variable "location" {
  description = "(Required) location of the to be used"  
}

variable "keyvault" {
  description = "(Required) keyvault to be referenced"  
}

variable "identity" {
  description = "(Required) UserAssignedIdentity for keyvault access by the appgw"  
}

variable "resource-groups" {
  description = "(Required) Resource Group of the Resource Groups to be created"  
}

variable "networking" {
  description = "(Required) Networking to be created"  
}

variable "web-app" {
  description = "(Required) web-app to be created"  
  
}

variable "sql" {
  description = "(Required) sql to be created"  

}

variable "storage" {
  description = "(Required) storage to be created"  

}

variable "redis" {
    description = "(Required) redis to be created"  
}

variable "appgw" {
    description = "(Required) appgw to be created"  
}

