terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_k9s_aztest" {
  name     = "rg_k9s_aztest"
  location = "brazilsouth"
}

resource "azurerm_virtual_network" "rg_k9s_aztest" {
  name                = "ex-network"
  resource_group_name = azurerm_resource_group.rg_k9s_aztest
  location            = azurerm_resource_group.rg_k9s_aztest
  address_space       = ["0.0.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "test_k8s" {
  name                = "live_clust"
  location            = azurerm_resource_group.rg_k9s_aztest
  resource_group_name = azurerm_resource_group.rg_k9s_aztest
  dns_prefix          = "live_clust"

  default_node_pool {
    name       = "default"
    node_count = "2"
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }

}

output "kube_acess" {
  value = azurerm_kubernetes_cluster.test_k8s.kube_config_raw
}

resource "local_file" "kube_config" {
  content = azurerm_kubernetes_cluster.test_k8s.kube_config_raw
  filename = "kubeconfig"
}