variable "nom_du_rg" {
  description = "Nom du Groupe de Ressources (passé par la racine)"
  type        = string
}

variable "emplacement" {
  description = "Région Azure (passée par la racine)"
  type        = string
}

variable "nom_projet" {
  description = "Nom technique du projet pour le nommage des ressources"
  type        = string
}

variable "subnet_id" {
  description = "ID du sous-réseau où brancher la VM (vient du module network)"
  type        = string
}

variable "vm_size" {
  description = "Taille de la machine virtuelle"
  type        = string
  default     = "Standard_B1s"
}