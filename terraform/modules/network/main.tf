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

resource "azurerm_network_security_group" "nsg_projet" {
  name                = "nsg-ibra-devops"
  location            = var.emplacement
  resource_group_name = var.nom_du_rg

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPing"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "snet_assoc" {
  subnet_id                 = azurerm_subnet.subnet_interne.id
  network_security_group_id = azurerm_network_security_group.nsg_projet.id
}