variable "nom_projet" {
    description = "Le nom pour les ressources du projet"
    type = string
    default = "ibra-devops"
}

variable "region" {
    description = "La localisation géographique des ressources"
    type = string
    default = "germanywestcentral"
}

variable "env" {
  description = "Le type d'environnement (dev, test, prod)"
  type        = string
  default     = "dev"
}