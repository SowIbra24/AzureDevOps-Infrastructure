resource "azurerm_virtual_network" "vnet" {
  name                = var.nom_du_vnet
  location            = var.emplacement
  resource_group_name = var.nom_du_rg
  address_space       = var.adresse_vnet
}

resource "azurerm_subnet" "subnet_interne" {
  name                 = "snet-interne"
  resource_group_name  = var.nom_du_rg
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}