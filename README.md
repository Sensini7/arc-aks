# ARC-AKS Terraform


This repository contains Terraform code for deploying a GitHub Actions runner environment on Azure Kubernetes Service (AKS) with Azure Arc. The configuration provisions an AKS cluster, installs the Arc runner controller, creates the required Kubernetes namespace and secrets, and deploys a runner scale set via Helm.

The infrastructure is organised in modules so that each Azure or Kubernetes resource can be managed individually. Terraform remote state is stored in Azure Storage as defined in `backend.tf`.

## Controls Satisfied
- NIST 800-53 [CM-2](https://csf.tools/reference/nist-sp-800-53/r5/cm/cm-2/) - Baseline Configuration
- NIST 800-53 [CM-6](https://csf.tools/reference/nist-sp-800-53/r5/cm/cm-6/) - Configuration Settings
- NIST 800-53 [SC-7](https://csf.tools/reference/nist-sp-800-53/r5/sc/sc-7/) - Boundary Protection
- NIST 800-53 [SI-4](https://csf.tools/reference/nist-sp-800-53/r5/si/si-4/) - System Monitoring

## Table of Contents

1. [How to Use This Module](#how-to-use-this-module)
2. [Module Documentation](#module-documentation)
   - [Requirements](#requirements)
   - [Providers](#providers)
   - [Modules](#modules)
   - [Resources](#resources)
   - [Inputs](#inputs)
   - [Outputs](#outputs)

## How to Use This Module

```hcl
module "arc_aks" {
  source = "git::https://github.com/YourOrg/arc-aks.git?ref=1.0.0"

  rg_name   = "rg-gha-runners"
  location  = "eastus"

  aks_name   = "arc-aks"
  dns_prefix = "arcaks"

  github_app_id              = var.github_app_id
  github_app_installation_id = var.github_app_installation_id
  github_app_private_key     = var.github_app_private_key
}
```

Run `terraform init` and `terraform apply` to provision the resources.


### Required Azure Permissions
- Contributor on the target resource group
- Permissions to create Kubernetes resources via Azure Arc


## Module Documentation
<!-- BEGIN_TF_DOCS -->
### Requirements
| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.100.0 |
| kubernetes | >= 2.7.0 |
| helm | >= 2.12.1 |

### Providers
| Name | Version |
|------|---------|
| azurerm | >= 3.100.0 |
| kubernetes | >= 2.7.0 |
| helm | >= 2.12.1 |

### Modules
| Name | Source | Version |
|------|--------|---------|
| resource_group | ./modules/resource_group | n/a |
| aks | ./modules/aks | n/a |
| arc_namespace | ./modules/arc_namespace | n/a |
| arc_controller | ./modules/arc_controller | n/a |
| github_secret | ./modules/github_secret | n/a |
| arc_runner_scaleset | ./modules/arc_runner_scaleset | n/a |

### Resources
| Name | Type |
|------|------|
| azurerm_kubernetes_cluster | resource |
| azurerm_resource_group | resource |
| kubernetes_namespace | resource |
| helm_release | resource |
| kubernetes_secret | resource |


### Inputs
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `location` | Azure region | `string` | `"eastus"` |
| `rg_name` | Resource group name | `string` | n/a |
| `aks_name` | AKS cluster name | `string` | n/a |
| `dns_prefix` | AKS DNS prefix | `string` | n/a |
| `node_count` | AKS node count | `number` | `2` |
| `vm_size` | AKS VM size | `string` | `"Standard D2s v6"` |
| `github_app_id` | GitHub App ID | `string` | n/a |
| `github_app_installation_id` | GitHub App installation ID | `string` | n/a |
| `github_app_private_key` | GitHub App private key | `string` | n/a |
| `github_config_url` | Repository or organisation URL | `string` | `"https://github.com/Sensini7/arc-aks"` |
| `runner_group` | GitHub runner group | `string` | `"Default"` |
| `min_runners` | Minimum number of runners | `number` | `0` |
| `max_runners` | Maximum number of runners | `number` | `10` |
| `runner_image` | Runner container image | `string` | `"ghcr.io/actions/actions-runner:latest"` |
| `arc_runner_release_name` | Helm release name | `string` | `"arc-runner-set"` |

### Outputs
| Name | Description |
|------|-------------|
| `kube_config` | Kube config for the AKS cluster |
| `arc_namespace` | Name of the ARC namespace |
| `resource_group_name` | Resource group name |
| `aks_cluster_name` | AKS cluster name |
<!-- END_TF_DOCS -->
