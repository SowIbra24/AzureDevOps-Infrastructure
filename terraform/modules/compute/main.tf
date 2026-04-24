
resource "azurerm_public_ip" "public_ip" {
  name                = "public_ip-${var.nom_projet}"
  location            = var.emplacement
  resource_group_name = var.nom_du_rg
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.nom_projet}"
  location            = var.emplacement
  resource_group_name = var.nom_du_rg
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${var.nom_projet}"
  resource_group_name = var.nom_du_rg
  location            = var.emplacement
  size                = var.vm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}