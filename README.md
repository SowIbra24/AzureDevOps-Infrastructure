# Projet Infrastructure as Code & CI/CD sur Azure

## Présentation du Projet
Ce projet a pour objectif de mettre en pratique les concepts fondamentaux de la culture **DevOps** et de l'**Infrastructure as Code (IaC)**. 

L'enjeu est de démontrer la capacité à automatiser entièrement le cycle de vie d'une infrastructure cloud : du provisioning des ressources sur **Microsoft Azure** jusqu'à leur configuration logicielle, le tout piloté par un pipeline **CI/CD Azure** industriel.

---
## Stack Technique
* **Cloud Provider :** Microsoft Azure
* **Gestionnaire de version :** GitHub
* **Orchestrateur CI/CD :** Azure DevOps
* **Provisioning :** Terraform (Approche modulaire)
* **Configuration Management :** Ansible (Roles & Collections)

---
## Configuration de l'environnement (Préliminaires)

Avant de débuter l'écriture du code, une phase de préparation de l'environnement Azure et de la plateforme DevOps a été réalisée :

### 1. Sécurisation des accès (Azure Entra ID)
* Création d'une **App Registration** (`AzureDevOps-Config-Bot`) agissant comme un Service Principal.
* Assignation du rôle **Contributeur** sur l'abonnement Azure pour permettre l'automatisation des ressources.
* Génération d'un **Client Secret** sécurisé pour l'authentification.

### 2. Connectivité Azure DevOps
* Mise en place d'une **Service Connection** manuelle dans Azure DevOps.
* Cette connexion permet de faire le pont entre le pipeline de déploiement et l'abonnement Azure sans jamais exposer de secrets dans le code source public sur GitHub.

---
## Organisation du Dépôt
Le projet est structuré de manière à séparer les responsabilités :

```text
.
├── terraform/                # Infrastructure as Code
│   ├── modules/              # Composants réutilisables (Network, VM)
│   ├── main.tf               # Déclaration des ressources/modules
│   ├── variables.tf          # Définition des variables d'entrée
│   └── outputs.tf            # Informations de sortie (IPs)
├── ansible/                  # Configuration Management
│   ├── roles/                # Unités de configuration (Common, Web, App)
│   ├── group_vars/           # Variables de configuration par groupes
│   └── site.yml              # Playbook principal
└── azure-pipelines.yml       # Définition du pipeline de déploiement
```

## Tag v1.0.0 : Mise en place de l'architecture réseau

Cette première étape a consisté à poser les fondations réseau de l'infrastructure sur Azure de manière modulaire :
* **Resource Group** : Création d'un conteneur logique pour isoler et gérer le cycle de vie des ressources.
* **Virtual Network (VNet)** : Mise en place de l'espace d'adressage global (10.0.0.0/16).
* **Subnet** : Segmentation réseau (10.0.1.0/24) pour accueillir les futures machines virtuelles.

---

### 🚀 Exécution du projet

#### Pré-requis
1. Disposer de **Azure CLI** et **Terraform** sur votre machine.
2. Une paire de clés SSH (`~/.ssh/id_rsa.pub`) pour l'accès aux futures VMs.

#### Procédure de lancement
Suivez ces étapes pour déployer l'infrastructure :

 ```bash
# 1. Authentification Azure:
    az login

# 2. Configuration de l'abonnement :
# Exportez votre ID de souscription pour orienter le déploiement :
    export ARM_SUBSCRIPTION_ID="votre_id_subscription_ici"

# 3. Déploiement avec Terraform :
# Récupération du dépôt
    git clone <url_de_votre_depot>
    cd terraform

# Initialisation (chargement des providers et modules)
    terraform init

# Visualisation du plan d'exécution
    terraform plan

# Application et création des ressources
    terraform apply 
```
#### Vérification 
 Une fois terminé, connectez-vous au portail Azure pour visualiser le groupe de ressources et la topologie réseau créée. Les outputs Terraform afficheront également les IDs des ressources générées.

## Retours d'expérience & Troubleshooting

Le déploiementa été ardu. Voici les points de frictions et les solutions appliquées :

* **Quotas Azure (SKU Not Available) :** Échec initial en *West Europe* et *Spain Central* (saturation des ressources pour les comptes Students).
  * **Solution :** Migration vers **Poland Central** (`polandcentral`) après avoir testé les autres destinations autorisées pour garantir la disponibilité des instances.

* **Désynchronisation du State :** Crash du provider pendant un `apply`, créant des ressources "orphelines" (présentes sur Azure mais absentes du `.tfstate`).
  * **Solution :** Réconciliation manuelle via `terraform import` pour réaligner le code avec la réalité du Cloud.

* **Isolation Réseau :** VM "Running" mais injoignable (Timeout SSH/Ping) dû au "Deny All" par défaut d'Azure.
  * **Solution :** Création d'un **Network Security Group (NSG)** lié au Subnet avec des règles explicites pour le port **22 (TCP)** et le protocole **ICMP (Ping)**.

### État Actuel : VM Linux Opérationnelle
L'infrastructure de base est désormais stable. Une machine virtuelle Linux est déployée, répond au ping et peut être entièrement administrée via SSH.

---

## Prochaines étapes
1. **Scaling :** Déploiement d'une 2ème VM via le module `compute`.
2. **Ansible :** Automatisation de la configuration logicielle (Rôles & Collections) sur l'ensemble du parc.