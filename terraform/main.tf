resource "azurerm_resource_group" "rg_projet" {
  name     = "rg-${var.nom_projet}-${var.env}"
  location = var.region
}

module "reseau_principal" {
    source = "./modules/network"

    nom_du_vnet =  "vnet-${var.nom_projet}"
    emplacement = azurerm_resource_group.rg_projet.location 
    nom_du_rg = azurerm_resource_group.rg_projet.name 
    adresse_vnet = ["10.0.0.0/16"] 
}
