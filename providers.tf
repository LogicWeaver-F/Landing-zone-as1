terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }

  # Optional: Configure backend for state management
  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "tfstate${random_string.suffix.result}"
  #   container_name       = "tfstate"
  #   key                  = "landing-zone.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}