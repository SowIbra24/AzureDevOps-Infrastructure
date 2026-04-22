output "vnet_id_final" {
  description = "L'ID du réseau virtuel créé"
  value       = module.reseau_principal.vnet_id 
}

output "subnet_id_final" {
  description = "L'ID du subnet pour la future VM"
  value       = module.reseau_principal.subnet_id
}

output "vnet_name" {
    description = "Nom du Vnet"
    value = module.reseau_principal.vnet_name
}

output "final_resource_group_name" {
  value = azurerm_resource_group.rg_projet.name
}