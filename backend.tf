terraform {
  backend "azurerm" {
    resource_group_name  = "Runner"
    storage_account_name = "sensiniecistate"
    container_name       = "eci-state"
    key                  = "arc-aks.tfstate"
  }
}
