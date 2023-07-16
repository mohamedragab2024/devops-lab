resource "azurerm_resource_group" "aks-rg" {
  name     = var.resource_group_name_prefix
  location = var.resource_group_location
}
resource "azurerm_kubernetes_cluster" "aks" {
  name   = var.resource_name
  location = var.resource_group_location
  resource_group_name =  azurerm_resource_group.aks-rg.name
  dns_prefix = var.dns_prefix
  default_node_pool {
    name = var.node_name_perfix
    vm_size = var.vm_size
    enable_auto_scaling = true
    min_count           = var.min_node_count
    os_disk_size_gb = var.os_disk_size_gb
    max_count           = var.max_node_count
    zones = []
    type = var.default_pool_type
  }

 identity {
   type = "SystemAssigned"
 }
  network_profile {
    network_plugin = var.network_plugin
    load_balancer_sku = var.load_balancer_sku
    network_policy = var.network_policy
  }

  tags = {
    envrionment = "hands-on-lab"
  }
  
}
