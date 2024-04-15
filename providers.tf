terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.95.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-sanhorva"
    storage_account_name = "sasanhorva"
    container_name       = "tfstate-shsz-03"
    key                  = "prod.terraform.tfstate"
  }
}