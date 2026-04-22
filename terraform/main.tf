resource "azurerm_resource_group" "rg_projet" {
  name     = "rg-${var.nom_projet}-${var.env}"
  location = var.region
}