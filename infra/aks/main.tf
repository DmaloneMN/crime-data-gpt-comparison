provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "crime_rg" {
  name     = "crime-analysis-rg"
  location = "East US"
}

resource "azurerm_key_vault" "crime_kv" {
  name                = "crime-analysis-kv"
  resource_group_name = azurerm_resource_group.crime_rg.name
  location            = azurerm_resource_group.crime_rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_kubernetes_cluster" "crime_aks" {
  name                = "crime-analysis-aks"
  location            = azurerm_resource_group.crime_rg.location
  resource_group_name = azurerm_resource_group.crime_rg.name
  dns_prefix          = "crimeaks"
  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }
  identity {
    type = "SystemAssigned"
  }
}
