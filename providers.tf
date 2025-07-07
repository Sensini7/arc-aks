terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.100.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.7.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.12.1"
    }
  }
  required_version = ">=1.5.0"
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Kubernetes & Helm providers configured after AKS deployment (see main.tf)
