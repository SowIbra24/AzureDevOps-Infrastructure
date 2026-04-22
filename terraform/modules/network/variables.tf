variable "nom_du_vnet" {
  description = "Nom du réseau virtuel"
  type        = string
}

variable "emplacement" {
  description = "Région Azure (passée par la racine)"
  type        = string
}

variable "nom_du_rg" {
  description = "Nom du Groupe de Ressources (passé par la racine)"
  type        = string
}

variable "adresse_vnet" {
  description = "Plage d'adresses du VNet"
  type        = list(string)
}