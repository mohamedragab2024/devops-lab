variable "resource_group_location" {
  type        = string
  default     = "eastus"
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "IOTHub-rg"
}

variable "resource_name" {
  type = string
  default = "my-aks"
}

variable "dns_prefix" {
  type = string
  default = "my-aks"
}
variable "node_name_perfix" {
  type        = string
  default     = "aks_node"
}
variable "max_node_count" {
  type        = number
  default     = 3
}

variable "min_node_count" {
  type        = number
  default     = 1
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
}

variable "os_type" {
  type        = string
  default     = "Linux"
}

variable "os_disk_size_gb" {
  type        = string
}
variable "default_pool_type" {
  type = string
}
variable "network_plugin" {
  type        = string
  default     = "Azure CNI"
}

variable "network_policy" {
  type        = string
  default     = "Calico"
}

variable "load_balancer_sku" {
  type = string
  default = "Standard"
}


