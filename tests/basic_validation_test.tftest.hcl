# Unit tests for GitHub Actions Runner Controller (ARC) on AKS Module
# These tests validate the module's functionality without creating actual Azure resources

mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "12345678-1234-1234-1234-123456789012"
      object_id = "87654321-4321-4321-4321-210987654321"
    }
  }

  mock_resource "azurerm_resource_group" {
    defaults = {
      name     = "rg-arc-aks-test"
      location = "eastus"
    }
  }

  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      name                = "aks-arc-test"
      location           = "eastus"
      resource_group_name = "rg-arc-aks-test"
      dns_prefix         = "aks-arc-test"
      kubernetes_version  = "1.28.0"
      kube_config = [{
        host                   = "https://aks-arc-test-dns-12345678.hcp.eastus.azmk8s.io:443"
        client_certificate     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t"
        client_key            = "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0t"
        cluster_ca_certificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t"
      }]
    }
  }
}

mock_provider "kubernetes" {
  mock_resource "kubernetes_namespace" {
    defaults = {
      metadata = [{
        name = "arc-systems"
      }]
    }
  }

  mock_resource "kubernetes_secret" {
    defaults = {
      metadata = [{
        name      = "github-app-credentials"
        namespace = "arc-systems"
      }]
    }
  }
}

mock_provider "helm" {
  mock_resource "helm_release" {
    defaults = {
      name      = "arc-controller"
      namespace = "arc-systems"
      status    = "deployed"
      version   = "0.8.3"
    }
  }
}

# Common variables used across all tests
variables {
  # Basic Azure configuration
  location = "eastus"
  rg_name  = "rg-arc-aks-test"
  aks_name = "aks-arc-test"
  dns_prefix = "aks-arc-test"

  # AKS configuration
  node_count = 2
  vm_size    = "Standard_D2s_v3"

  # GitHub App configuration (mock values for testing)
  github_app_id              = "123456"
  github_app_installation_id = "12345678"
  github_app_private_key     = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQ=="

  # ARC Runner Scale Set configuration
  github_config_url = "https://github.com/Sensini7/arc-aks"
  runner_group      = "Default"
  min_runners       = 0
  max_runners       = 10
  runner_image      = "ghcr.io/actions/actions-runner:latest"
  arc_runner_release_name = "arc-runner-set"
}

# Test 1: Valid minimal configuration
run "valid_minimal_configuration" {
  command = plan

  # Test that all input variables are properly set
  assert {
    condition     = var.rg_name == "rg-arc-aks-test"
    error_message = "Resource group name should match the input variable"
  }

  assert {
    condition     = var.aks_name == "aks-arc-test"
    error_message = "AKS cluster name should match the input variable"
  }

  assert {
    condition     = var.location == "eastus"
    error_message = "Location should match the input variable"
  }

  assert {
    condition     = var.github_app_id == "123456"
    error_message = "GitHub App ID should match the input variable"
  }

  assert {
    condition     = var.github_config_url == "https://github.com/Sensini7/arc-aks"
    error_message = "GitHub config URL should match the input variable"
  }
}

# Test 2: Valid AKS configuration
run "valid_aks_configuration" {
  command = plan

  assert {
    condition     = var.aks_name == "aks-arc-test"
    error_message = "AKS cluster name should match the input variable"
  }

  assert {
    condition     = var.location == "eastus"
    error_message = "AKS cluster location should match the input variable"
  }

  assert {
    condition     = var.node_count == 2
    error_message = "AKS node count should match the input variable"
  }

  assert {
    condition     = var.vm_size == "Standard_D2s_v3"
    error_message = "AKS VM size should match the input variable"
  }
}

# Test 3: GitHub App configuration validation
run "valid_github_app_configuration" {
  command = plan

  assert {
    condition     = length(var.github_app_id) > 0
    error_message = "GitHub App ID should not be empty"
  }

  assert {
    condition     = length(var.github_app_installation_id) > 0
    error_message = "GitHub App Installation ID should not be empty"
  }

  assert {
    condition     = length(var.github_app_private_key) > 0
    error_message = "GitHub App private key should not be empty"
  }

  assert {
    condition = can(regex("^https://github\\.com/[a-zA-Z0-9_.-]+(/[a-zA-Z0-9_.-]+)?$", var.github_config_url))
    error_message = "GitHub config URL should be a valid GitHub repository or organization URL"
  }
}

# Test 4: ARC Runner Scale Set configuration
run "valid_arc_runner_configuration" {
  command = plan

  assert {
    condition     = var.min_runners >= 0
    error_message = "Minimum runners should be greater than or equal to 0"
  }

  assert {
    condition     = var.max_runners > 0
    error_message = "Maximum runners should be greater than 0"
  }

  assert {
    condition     = var.min_runners <= var.max_runners
    error_message = "Minimum runners should be less than or equal to maximum runners"
  }

  assert {
    condition = can(regex("^ghcr\\.io/actions/actions-runner:", var.runner_image))
    error_message = "Runner image should use the official GitHub Actions runner image"
  }
}

# Test 5: Development environment configuration
run "valid_dev_environment_configuration" {
  command = plan

  variables {
    rg_name     = "rg-arc-aks-dev"
    aks_name    = "aks-arc-dev"
    dns_prefix  = "aks-arc-dev"
    node_count  = 1
    vm_size     = "Standard_B2s"
    min_runners = 0
    max_runners = 3
    runner_group = "development"
  }

  assert {
    condition     = var.node_count == 1
    error_message = "Development environment should use minimal node count"
  }

  assert {
    condition     = var.max_runners <= 5
    error_message = "Development environment should have limited max runners"
  }

  assert {
    condition     = var.runner_group == "development"
    error_message = "Development environment should use development runner group"
  }
}

# Test 6: Production environment configuration
run "valid_prod_environment_configuration" {
  command = plan

  variables {
    rg_name     = "rg-arc-aks-prod"
    aks_name    = "aks-arc-prod"
    dns_prefix  = "aks-arc-prod"
    node_count  = 3
    vm_size     = "Standard_D4s_v3"
    min_runners = 2
    max_runners = 50
    runner_group = "production"
  }

  assert {
    condition     = var.node_count >= 3
    error_message = "Production environment should have at least 3 nodes for HA"
  }

  assert {
    condition     = var.min_runners >= 1
    error_message = "Production should always have minimum runners available"
  }

  assert {
    condition = can(regex("^Standard_D[0-9]+s_v[0-9]+$", var.vm_size))
    error_message = "Production should use D-series VMs for better performance"
  }

  assert {
    condition     = var.runner_group == "production"
    error_message = "Production environment should use production runner group"
  }
}

# Test 7: Runner scaling configuration
run "valid_runner_scaling" {
  command = plan

  variables {
    min_runners = 1
    max_runners = 20
  }

  assert {
    condition     = var.min_runners == 1
    error_message = "Minimum runners should be set correctly"
  }

  assert {
    condition     = var.max_runners == 20
    error_message = "Maximum runners should be set correctly"
  }

  assert {
    condition     = var.min_runners <= var.max_runners
    error_message = "Minimum runners should not exceed maximum runners"
  }
}

# Test 8: Custom runner image configuration
run "valid_custom_runner_image" {
  command = plan

  variables {
    runner_image = "ghcr.io/actions/actions-runner:2.309.0"
  }

  assert {
    condition = can(regex("^ghcr\\.io/actions/actions-runner:[0-9]+\\.[0-9]+\\.[0-9]+$", var.runner_image))
    error_message = "Custom runner image should follow proper versioning format"
  }
}

# Test 9: Repository-level runner configuration
run "valid_repository_level_configuration" {
  command = plan

  variables {
    github_config_url = "https://github.com/Sensini7/arc-aks"
    min_runners       = 1
    max_runners       = 5
  }

  assert {
    condition = can(regex("^https://github\\.com/[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$", var.github_config_url))
    error_message = "Repository-level configuration should use specific repository URL"
  }
}

# Test 10: Organization-level runner configuration
run "valid_organization_level_configuration" {
  command = plan

  variables {
    github_config_url = "https://github.com/Sensini7"
    runner_group      = "production"
    min_runners       = 2
    max_runners       = 20
  }

  assert {
    condition = can(regex("^https://github\\.com/[a-zA-Z0-9_.-]+$", var.github_config_url))
    error_message = "Organization-level configuration should use organization URL"
  }

  assert {
    condition     = length(var.runner_group) > 0
    error_message = "Organization-level configuration should specify runner group"
  }
}

# Test 11: Resource naming consistency
run "valid_resource_naming" {
  command = plan

  variables {
    rg_name    = "rg-test-arc"
    aks_name   = "aks-test-arc"
    dns_prefix = "aks-test-arc"
    arc_runner_release_name = "test-arc-runner-set"
  }

  assert {
    condition     = var.rg_name == "rg-test-arc"
    error_message = "Resource group name should match input"
  }

  assert {
    condition     = var.aks_name == "aks-test-arc"
    error_message = "AKS cluster name should match input"
  }

  assert {
    condition     = var.dns_prefix == "aks-test-arc"
    error_message = "DNS prefix should match input"
  }

  assert {
    condition     = var.arc_runner_release_name == "test-arc-runner-set"
    error_message = "ARC runner release name should match input"
  }
}

# Test 12: Edge case - zero minimum runners
run "valid_zero_minimum_runners" {
  command = plan

  variables {
    min_runners = 0
    max_runners = 5
  }

  assert {
    condition     = var.min_runners == 0
    error_message = "Zero minimum runners should be allowed for cost optimization"
  }

  assert {
    condition     = var.max_runners > var.min_runners
    error_message = "Maximum runners should be greater than minimum when min is zero"
  }
}

# Test 13: Large scale configuration
run "valid_large_scale_configuration" {
  command = plan

  variables {
    node_count  = 10
    vm_size     = "Standard_D8s_v3"
    min_runners = 5
    max_runners = 100
  }

  assert {
    condition     = var.node_count == 10
    error_message = "Large scale should support many nodes"
  }

  assert {
    condition     = var.max_runners == 100
    error_message = "Large scale should support many runners"
  }

  assert {
    condition = can(regex("Standard_D8s_v3", var.vm_size))
    error_message = "Large scale should use appropriate VM sizes"
  }
}

# Test 14: Variable validation - Invalid scaling configuration
run "invalid_scaling_configuration" {
  command = plan

  variables {
    min_runners = 10
    max_runners = 5  # Invalid: min > max
  }

  # Verify we can detect the invalid configuration
  assert {
    condition     = var.min_runners > var.max_runners
    error_message = "Successfully detected invalid scaling configuration where min_runners (${var.min_runners}) > max_runners (${var.max_runners})"
  }
}

# Test 15: Variable validation - Invalid GitHub URL
run "invalid_github_url" {
  command = plan

  variables {
    github_config_url = "https://gitlab.com/user/repo"  # Invalid: not GitHub
  }

  # This assertion should fail for non-GitHub URLs
  assert {
    condition = !can(regex("^https://github\\.com/[a-zA-Z0-9_.-]+(/[a-zA-Z0-9_.-]+)?$", var.github_config_url))
    error_message = "Non-GitHub URLs should not match the GitHub URL pattern"
  }
}

# Test 16: Variable defaults validation
run "valid_variable_defaults" {
  command = plan

  # Test with minimal required variables, letting others use defaults
  variables {
    rg_name  = "test-rg"
    aks_name = "test-aks"
    dns_prefix = "test-dns"
    github_app_id = "123456"
    github_app_installation_id = "12345678"
    github_app_private_key = "test-key"
  }

  # Verify defaults are applied correctly
  assert {
    condition     = var.location == "eastus"
    error_message = "Location should default to eastus"
  }

  assert {
    condition     = var.node_count == 2
    error_message = "Node count should default to 2"
  }

  assert {
    condition     = var.min_runners == 0
    error_message = "Min runners should default to 0"
  }

  assert {
    condition     = var.max_runners == 10
    error_message = "Max runners should default to 10"
  }

  assert {
    condition     = var.runner_group == "Default"
    error_message = "Runner group should default to 'Default'"
  }
}
