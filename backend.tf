terraform {
  backend "azurerm" {
    resource_group_name  = "<RG_NAME>"
    storage_account_name = "<STORAGE_ACCOUNT_NAME>"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
