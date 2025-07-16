<!-- ARC-AKS-TF

# GitHub Actions ARC on AKS - Infrastructure as Code

This repo deploys a scalable, auto-scaling GitHub Actions runner environment on AKS using ARC and Terraform.
**Modules** for each major Azure/K8s resource, with backend state in Azure Storage.
Runner ScaleSet is deployed via Kubernetes manifest.

## Steps

1. Create a GitHub App, fill details into variables.
2. `terraform init` & `terraform apply`
3. Set up your `kubectl` context to AKS.
4. `kubectl apply -f manifests/arc-autoscale-runner.yaml`
5. Test workflows targeting your scale set.

See modules and root configs for details. -->

<!-- BEGIN_TF_DOCS -->
# Terraform GitHub Actions Runner Controller (ARC) on AKS Module

This module allows users to quickly deploy GitHub Actions Runner Controller (ARC) on Azure Kubernetes Service (AKS) that is aligned with the NIST 800-53 High security controls outlined in the [Azure security baseline for Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/azure-kubernetes-service-aks-security-baseline). It is designed to be simple to use and flexible enough to meet the needs of most organizations requiring secure, scalable, self-hosted GitHub Actions runners in Kubernetes.

**Note**: This module assumes a compliant AKS infrastructure baseline is already deployed. GitHub App configuration requires manual setup post-deployment for enhanced security. See the [Important Notes](#important-notes) section for details.

## Controls Satisfied
- NIST 800-53 [AC-3](https://csf.tools/reference/nist-sp-800-53/r5/ac/ac-3/) - Access Enforcement
- NIST 800-53 [AC-4](https://csf.tools/reference/nist-sp-800-53/r5/ac/ac-4/) - Information Flow Enforcement
- NIST 800-53 [AC-6](https://csf.tools/reference/nist-sp-800-53/r5/ac/ac-6/) - Least Privilege
- NIST 800-53 [IA-2](https://csf.tools/reference/nist-sp-800-53/r5/ia/ia-2/) - Identification and Authentication (Organizational Users)
- NIST 800-53 [IA-5](https://csf.tools/reference/nist-sp-800-53/r5/ia/ia-5/) - Authenticator Management
- NIST 800-53 [SC-7](https://csf.tools/reference/nist-sp-800-53/r5/sc/sc-7/) - Boundary Protection
- NIST 800-53 [SC-7(5)](https://csf.tools/reference/nist-sp-800-53/r5/sc/sc-7/sc-7-5/) - Deny by Default / Allow by Exception
- NIST 800-53 [SC-12](https://csf.tools/reference/nist-sp-800-53/r5/sc/sc-12/) - Cryptographic Key Establishment and Management
- NIST 800-53 [SC-13](https://csf.tools/reference/nist-sp-800-53/r5/sc/sc-13/) - Cryptographic Protection
- NIST 800-53 [SC-28](https://csf.tools/reference/nist-sp-800-53/r5/sc/sc-28/) - Protection of Information at Rest
- NIST 800-53 [CM-2](https://csf.tools/reference/nist-sp-800-53/r5/cm/cm-2/) - Baseline Configuration
- NIST 800-53 [CM-6](https://csf.tools/reference/nist-sp-800-53/r5/cm/cm-6/) - Configuration Settings
- NIST 800-53 [CP-2](https://csf.tools/reference/nist-sp-800-53/r5/cp/cp-2/) - Contingency Plan
- NIST 800-53 [SA-9](https://csf.tools/reference/nist-sp-800-53/r5/sa/sa-9/) - External System Services

## Required Azure Permissions

- Azure Kubernetes Service Cluster Admin
- Azure Kubernetes Service RBAC Admin
- Key Vault Administrator (for secrets management)
- Network Contributor (for network policies)
- Managed Identity Operator
- User Access Administrator (for managed identity role assignments)

## Azure Prerequisites

Before using this module, ensure the following Azure resources are created:

### Required Resources
- **AKS Cluster** - NIST 800-53 High compliant AKS cluster (see referenced baseline)
- **Azure Key Vault** - For storing GitHub App private keys and secrets
- **Virtual Network and Subnets** - With appropriate network security groups
- **Log Analytics Workspace** - For monitoring and logging
- **Azure Container Registry** (optional) - For custom runner images

### GitHub Prerequisites
- **GitHub Enterprise Cloud or Server** environment
- **GitHub App** created with the following permissions:
  - **Repository permissions:**
    - Actions: Read and Write
    - Administration: Read (for runner group access)
    - Checks: Read
    - Contents: Read
    - Metadata: Read
    - Pull requests: Read
  - **Organization permissions:**
    - Self-hosted runners: Write
- **GitHub App Installation** on target organization/repository
- **Runner Groups** configured (if using organization-level runners)

## Table of Contents

1. [How to use this module](#how-to-use-this-module)
1. [Supported Resource Types](#supported-resource-types)
1. [Why this module?](#why-this-module)
1. [Module Documentation](#module-documentation)
    1. [Requirements](#requirements)
    1. [Providers](#providers)
    1. [Modules](#modules)
    1. [Resources](#resources)
    1. [Inputs](#inputs)
    1. [Outputs](#outputs)

---

# How to use this module

## Basic Usage (Organization-Level Runners)

```hcl
module "github_actions_runner_controller" {
  source = "git::https://github.com/YourOrg/terraform-arc-aks-module.git?ref=1.0.0"

  # AKS Configuration
  aks_cluster_name        = "aks-prod-cluster"
  aks_resource_group_name = "rg-aks-prod"
  aks_cluster_id          = var.aks_cluster_id

  # ARC Controller Configuration
  arc_namespace           = "arc-systems"
  arc_chart_version      = "0.8.3"
  arc_controller_name    = "arc-controller"

  # Runner Scale Set Configuration
  runner_scale_sets = [
    {
      name                = "prod-runners"
      namespace          = "arc-runners"
      github_config_url  = "https://github.com/YourOrg"
      runner_group       = "production"
      min_runners        = 3
      max_runners        = 100
      container_mode     = "kubernetes"
      runner_image       = "ghcr.io/actions/actions-runner:latest"
    },
    {
      name                = "dev-runners"
      namespace          = "arc-runners-dev"
      github_config_url  = "https://github.com/YourOrg"
      runner_group       = "development"
      min_runners        = 1
      max_runners        = 25
      container_mode     = "kubernetes"
      runner_image       = "ghcr.io/actions/actions-runner:latest"
    }
  ]

  # GitHub App Authentication
  github_app_id              = var.github_app_id
  github_app_installation_id = var.github_app_installation_id
  github_app_private_key_path = var.github_app_private_key_path

  # Azure Key Vault Integration
  key_vault_id                = var.key_vault_id
  enable_key_vault_secrets    = true

  # Network Security
  enable_network_policies     = true
  allowed_egress_cidrs       = [
    "140.82.112.0/20",    # GitHub.com
    "143.55.64.0/20",     # GitHub.com
    "185.199.108.0/22"    # GitHub Pages/Assets
  ]

  # Pod Security
  pod_security_standard      = "restricted"
  enable_pod_security_policy = true

  # Storage Configuration (for Kubernetes mode)
  storage_class_name         = "managed-csi-premium"
  persistent_volume_size     = "10Gi"

  # Monitoring and Logging
  enable_prometheus_metrics  = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Tags
  tags = {
    Environment   = "production"
    Project       = "github-actions"
    Owner         = "platform-team"
    Compliance    = "NIST-800-53-High"
    CostCenter    = "infrastructure"
  }
}
Repository-Level Runners
hcl

Copy
module "github_actions_runner_controller" {
  source = "git::https://github.com/YourOrg/terraform-arc-aks-module.git?ref=1.0.0"

  # AKS Configuration
  aks_cluster_name        = "aks-prod-cluster"
  aks_resource_group_name = "rg-aks-prod"
  aks_cluster_id          = var.aks_cluster_id

  # ARC Controller Configuration
  arc_namespace           = "arc-systems"
  arc_chart_version      = "0.8.3"

  # Repository-specific Runner Scale Set
  runner_scale_sets = [
    {
      name                = "critical-app-runners"
      namespace          = "arc-runners-critical"
      github_config_url  = "https://github.com/YourOrg/critical-application"
      runner_group       = null  # Not applicable for repository-level
      min_runners        = 2
      max_runners        = 50
      container_mode     = "kubernetes"
      runner_image       = "your-registry.azurecr.io/custom-runner:latest"

      # Custom resource requirements
      resource_requests = {
        cpu    = "1"
        memory = "2Gi"
      }
      resource_limits = {
        cpu    = "4"
        memory = "8Gi"
      }
    }
  ]

  # GitHub App Authentication
  github_app_id              = var.github_app_id
  github_app_installation_id = var.github_app_installation_id
  github_app_private_key_path = var.github_app_private_key_path

  # Enhanced Security Configuration
  enable_network_policies     = true
  enable_pod_security_policy = true
  pod_security_standard      = "restricted"

  # Custom Container Registry
  container_registry_server   = "your-registry.azurecr.io"
  container_registry_username = var.acr_username
  container_registry_password = var.acr_password

  tags = {
    Environment = "production"
    Application = "critical-app"
    Compliance  = "NIST-800-53-High"
  }
}
High Availability Configuration
hcl

Copy
module "github_actions_runner_controller" {
  source = "git::https://github.com/YourOrg/terraform-arc-aks-module.git?ref=1.0.0"

  # AKS Configuration
  aks_cluster_name        = "aks-prod-cluster"
  aks_resource_group_name = "rg-aks-prod"
  aks_cluster_id          = var.aks_cluster_id

  # High Availability ARC Controller
  arc_namespace           = "arc-systems"
  arc_controller_replicas = 3
  arc_chart_version      = "0.8.3"

  # HA Runner Scale Sets with failover
  runner_scale_sets = [
    {
      name                = "ha-prod-runners-primary"
      namespace          = "arc-runners-primary"
      github_config_url  = "https://github.com/YourOrg"
      runner_group       = "production-primary"
      min_runners        = 5
      max_runners        = 200
      container_mode     = "kubernetes"

      # Affinity rules for HA
      node_affinity = {
        preferred = [
          {
            weight = 100
            preference = {
              match_expressions = [
                {
                  key      = "node.kubernetes.io/availability-zone"
                  operator = "In"
                  values   = ["eastus-1", "eastus-2"]
                }
              ]
            }
          }
        ]
      }
    },
    {
      name                = "ha-prod-runners-secondary"
      namespace          = "arc-runners-secondary"
      github_config_url  = "https://github.com/YourOrg"
      runner_group       = "production-secondary"
      min_runners        = 2
      max_runners        = 100
      container_mode     = "kubernetes"

      # Different zone affinity for failover
      node_affinity = {
        preferred = [
          {
            weight = 100
            preference = {
              match_expressions = [
                {
                  key      = "node.kubernetes.io/availability-zone"
                  operator = "In"
                  values   = ["eastus-3"]
                }
              ]
            }
          }
        ]
      }
    }
  ]

  # GitHub App Authentication
  github_app_id              = var.github_app_id
  github_app_installation_id = var.github_app_installation_id
  github_app_private_key_path = var.github_app_private_key_path

  # Backup and Disaster Recovery
  enable_backup_policies     = true
  backup_retention_days      = 30

  tags = {
    Environment = "production"
    Deployment  = "high-availability"
    Compliance  = "NIST-800-53-High"
  }
}
Supported Resource Types
This module creates and manages the following Azure and Kubernetes resources:

Kubernetes Namespaces - Dedicated namespaces for ARC components and runners
Helm Releases - ARC controller and runner scale set Helm deployments
Kubernetes Secrets - GitHub App authentication and container registry credentials
Service Accounts - Dedicated service accounts with minimal RBAC permissions
Network Policies - Pod-to-pod communication controls and egress filtering
Pod Security Policies - Container security contexts and restrictions
Persistent Volume Claims - Storage for Kubernetes mode containers (when enabled)
RBAC ClusterRoles and RoleBindings - Granular permissions for ARC components
ConfigMaps - ARC configuration and runner templates
Azure Key Vault Secrets - Secure storage for GitHub App private keys
Azure Role Assignments - Managed identity permissions for Key Vault access
Why this Module?
Consistent Security-First ARC Deployment
This module is designed to deploy GitHub Actions Runner Controller with security controls enabled by default on a compliant AKS infrastructure. It ensures that all ARC components are deployed with consistent security configurations, reducing the risk of misconfigurations that could lead to security vulnerabilities or compromise of CI/CD pipelines.

NIST 800-53 High Compliance Out-of-the-Box
The module implements security controls that align with NIST 800-53 High requirements, making it easier for organizations to meet compliance standards for their CI/CD infrastructure without having to manually configure each security feature.

Production-Ready Self-Hosted Runners
While security is the primary focus, the module provides enterprise-grade features:

Support for multiple runner scale sets with different configurations
High availability and automatic failover capabilities
Integration with Azure Key Vault for secrets management
Custom container image support with private registry integration
Comprehensive monitoring and logging integration
Operational Excellence
Infrastructure as Code approach with Helm chart management
Automated scaling based on GitHub Actions job queue
Network isolation with Kubernetes Network Policies
Pod security with restricted security contexts
Persistent storage for stateful workloads
Backup and disaster recovery capabilities
Important Notes
GitHub App Configuration
This module requires a GitHub App to be created and configured before deployment. The GitHub App provides secure, fine-grained access control and is the recommended authentication method over Personal Access Tokens.

Required GitHub App Permissions:

Repository permissions:
Actions: Read and Write
Administration: Read
Checks: Read
Contents: Read
Metadata: Read
Pull requests: Read
Organization permissions:
Self-hosted runners: Write
AKS Infrastructure Prerequisites
This module assumes you have a NIST 800-53 High compliant AKS cluster deployed. Ensure your AKS cluster includes:

Azure AD integration enabled
Network policies enabled (Azure CNI with Calico or Azure Network Policies)
Pod Security Standards enforced
Azure Key Vault Provider for Secrets Store CSI driver installed
Monitoring and logging configured
Post-Deployment Configuration Steps
After successful Terraform deployment, complete these manual steps:

Verify ARC Controller Status:

bash

Copy
kubectl get pods -n arc-systems
kubectl get runners --all-namespaces
Check Runner Scale Set Registration:

bash

Copy
# Verify runners are registered with GitHub
kubectl logs -n arc-runners deployment/arc-runner-set-listener
Test Runner Connectivity:
Create a simple GitHub Actions workflow to test runner connectivity:

yaml

Copy
name: Test ARC Runners
on: [workflow_dispatch]
jobs:
  test:
    runs-on: [self-hosted, production]
    steps:
      - name: Test runner
        run: echo "ARC runner is working!"
Configure Workflow Labels:
Update your GitHub Actions workflows to use the appropriate runner labels:

yaml

Copy
runs-on: [self-hosted, production]  # For production runner group
runs-on: [self-hosted, development] # For development runner group
Security Considerations
GitHub App private keys are stored securely in Azure Key Vault
Runner pods use minimal security contexts with non-root users
Network policies restrict egress to only necessary GitHub.com endpoints
All inter-pod communication is encrypted in transit
Persistent volumes use encryption at rest
Comprehensive audit logging is enabled for all ARC components
Container Mode Selection
Kubernetes Mode (Recommended): Uses Kubernetes pods for job containers, providing better security isolation
Docker-in-Docker Mode: Required for legacy workflows that need Docker socket access, but requires additional security considerations
Module Documentation
Requirements
Name	Version
<a name="requirement_terraform"></a> terraform	>= 1.0
<a name="requirement_azurerm"></a> azurerm	~> 4.32.0
<a name="requirement_helm"></a> helm	~> 2.15.0
<a name="requirement_kubernetes"></a> kubernetes	~> 2.32.0
Providers
Name	Version
<a name="provider_azurerm"></a> azurerm	4.32.0
<a name="provider_helm"></a> helm	2.15.0
<a name="provider_kubernetes"></a> kubernetes	2.32.0
Modules
No modules.

Resources
Name	Type
azurerm_key_vault_secret.github_app_private_key	resource
helm_release.arc_controller	resource
helm_release.runner_scale_sets	resource
kubernetes_namespace.arc_namespaces	resource
kubernetes_network_policy.arc_network_policies	resource
kubernetes_secret.github_app_auth	resource
kubernetes_secret.container_registry	resource
kubernetes_service_account.arc_service_accounts	resource
azurerm_kubernetes_cluster.aks	data source
Inputs
Name	Description	Type	Default	Required
<a name="input_aks_cluster_id"></a> aks_cluster_id	The resource ID of the AKS cluster	string	n/a	yes
<a name="input_aks_cluster_name"></a> aks_cluster_name	Name of the AKS cluster	string	n/a	yes
<a name="input_aks_resource_group_name"></a> aks_resource_group_name	Name of the resource group containing the AKS cluster	string	n/a	yes
<a name="input_allowed_egress_cidrs"></a> allowed_egress_cidrs	List of CIDR blocks allowed for egress traffic from runner pods	list(string)	<pre>[<br/> "140.82.112.0/20",<br/> "143.55.64.0/20",<br/> "185.199.108.0/22"<br/>]</pre>	no
<a name="input_arc_chart_version"></a> arc_chart_version	Version of the ARC Helm chart to deploy	string	"0.8.3"	no
<a name="input_arc_controller_name"></a> arc_controller_name	Name of the ARC controller Helm release	string	"arc-controller"	no
<a name="input_arc_controller_replicas"></a> arc_controller_replicas	Number of replicas for the ARC controller	number	1	no
<a name="input_arc_namespace"></a> arc_namespace	Kubernetes namespace for ARC controller components	string	"arc-systems"	no
<a name="input_container_registry_password"></a> container_registry_password	Password for private container registry access	string	null	no
<a name="input_container_registry_server"></a> container_registry_server	Private container registry server URL	string	null	no
<a name="input_container_registry_username"></a> container_registry_username	Username for private container registry access	string	null	no
<a name="input_enable_backup_policies"></a> enable_backup_policies	Whether to enable backup policies for ARC components	bool	false	no
<a name="input_enable_key_vault_secrets"></a> enable_key_vault_secrets	Whether to store GitHub App credentials in Azure Key Vault	bool	true	no
<a name="input_enable_network_policies"></a> enable_network_policies	Whether to create Kubernetes Network Policies for ARC components	bool	true	no
<a name="input_enable_pod_security_policy"></a> enable_pod_security_policy	Whether to enforce Pod Security Standards	bool	true	no
<a name="input_enable_prometheus_metrics"></a> enable_prometheus_metrics	Whether to enable Prometheus metrics for ARC components	bool	true	no
<a name="input_github_app_id"></a> github_app_id	GitHub App ID for authentication	string	n/a	yes
<a name="input_github_app_installation_id"></a> github_app_installation_id	GitHub App Installation ID	string	n/a	yes
<a name="input_github_app_private_key_path"></a> github_app_private_key_path	Path to the GitHub App private key file	string	n/a	yes
<a name="input_key_vault_id"></a> key_vault_id	Resource ID of the Azure Key Vault for storing secrets	string	null	no
<a name="input_log_analytics_workspace_id"></a> log_analytics_workspace_id	Log Analytics Workspace ID for monitoring	string	null	no
<a name="input_persistent_volume_size"></a> persistent_volume_size	Size of persistent volumes for Kubernetes mode runners	string	"10Gi"	no
<a name="input_pod_security_standard"></a> pod_security_standard	Pod Security Standard to enforce (baseline, restricted)	string	"restricted"	no
<a name="input_runner_scale_sets"></a> runner_scale_sets	List of runner scale sets to deploy	<pre>list(object({<br/> name = string<br/> namespace = string<br/> github_config_url = string<br/> runner_group = optional(string)<br/> min_runners = optional(number, 1)<br/> max_runners = optional(number, 25)<br/> container_mode = optional(string, "kubernetes")<br/> runner_image = optional(string, "ghcr.io/actions/actions-runner:latest")<br/> resource_requests = optional(object({<br/> cpu = optional(string, "500m")<br/> memory = optional(string, "1Gi")<br/> }), {})<br/> resource_limits = optional(object({<br/> cpu = optional(string, "2")<br/> memory = optional(string, "4Gi")<br/> }), {})<br/> node_affinity = optional(object({<br/> preferred = optional(list(object({<br/> weight = number<br/> preference = object({<br/> match_expressions = list(object({<br/> key = string<br/> operator = string<br/> values = list(string)<br/> }))<br/> })<br/> })), [])<br/> }), {})<br/> }))</pre>	n/a	yes
<a name="input_storage_class_name"></a> storage_class_name	Storage class name for persistent volumes	string	"managed-csi-premium"	no
<a name="input_tags"></a> tags	Tags to apply to all resources	map(string)	{}	no
Outputs
Name	Description
<a name="output_arc_controller_status"></a> arc_controller_status	Status information for the ARC controller deployment
<a name="output_compliance_information"></a> compliance_information	Information for NIST 800-53 High compliance verification
<a name="output_runner_scale_set_names"></a> runner_scale_set_names	Names of the deployed runner scale sets
<a name="output_runner_scale_set_namespaces"></a> runner_scale_set_namespaces	Kubernetes namespaces containing runner scale sets
<!-- END_TF_DOCS -->

sql_more

Copy

This README is specifically tailored to your GitHub Actions Runner Controller on AKS use case and includes:

1. **ARC-specific security controls** that align with your design document
2. **GitHub App permissions** as specified in your design document
3. **NIST 800-53 High compliance** focus
4. **Production-ready examples** including HA configurations
5. **Comprehensive configuration options** for different scenarios (org-level, repo-level, HA)
6. **Security-first approach** with network policies, pod security, and secrets management
7. **Post-deployment verification steps** specific to ARC
8. **Clear prerequisites** for both Azure and GitHub configurations

The README follows the structure of your sample but is completely focused on the ARC deployment scenario with appropriate technical details and security considerations.
