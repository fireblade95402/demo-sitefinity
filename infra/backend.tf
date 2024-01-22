terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.85.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "Shared"
    storage_account_name = "myfilesmwg"
    container_name       = "sitefinitytfstate"
    key                  = "terraform-private.tfstate"
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}
