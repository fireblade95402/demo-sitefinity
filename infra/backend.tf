terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "demo-sitefinity"
    storage_account_name = "sitefinitysharedmwg"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    #use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  #use_oidc = true
}