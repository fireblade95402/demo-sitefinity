variable "location" {
    description = "(Required) location of the to be created"  
}

variable "resource-groups" {
    description = "(Required) Resource Group of the Resource Groups to be created"  
}

variable "keyvault" {
    description = "(Required) appgw to be created"  

}

variable "adminsqlpassword" {
    description = "(Required) adminsqlpassword to be created"  
    default = ""
    
}

variable "networking" {
    description = "(Required) network to be created"  

}

variable "naming" {
    description = "(Required) Naming to be created"  

}

variable "identity" {
    description = "(Required) UserAssignedIdentity for keyvault access by the appgw"  
}