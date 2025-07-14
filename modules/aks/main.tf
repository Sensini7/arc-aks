resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  # Private cluster configuration
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_dns_zone_id

  # Workload identity and OIDC
  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled

  tags = var.tags

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = var.vnet_subnet_id

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  # Corrected syntax - remove the azure_active_directory_role_based_access_control block
  # and use role_based_access_control instead
  role_based_access_control_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    # Fix: Use non-overlapping service CIDR
    service_cidr       = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
  }
}