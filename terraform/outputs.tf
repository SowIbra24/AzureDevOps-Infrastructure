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

output "adresse_ip_vm" {
  description = "L'adresse IP publique pour se connecter à la VM"
  value       = module.ma_vm[*].vm_public_ip
}

resource "local_file" "inventory" {
  filename = "../ansible/inventory.ini"
  content  = <<EOF
[all]
%{ for i, ip in module.ma_vm[*].vm_public_ip ~}
vm-${i} ansible_host=${ip} ansible_user=adminuser
%{ endfor ~}
EOF
}