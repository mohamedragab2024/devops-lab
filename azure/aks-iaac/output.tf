resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.aks]
  filename = "kubeconfig"
  content      = azurerm_kubernetes_cluster.aks.kube_config_raw
}