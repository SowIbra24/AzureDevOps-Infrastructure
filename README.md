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

### Exécution du projet

#### Pré-requis
1. Disposer de **Azure CLI** et **Terraform** sur votre machine.
2. Une paire de clés SSH (`~/.ssh/id_rsa.pub`) pour l'accès aux futures VMs.

#### Procédure de lancement
Suivez ces étapes pour déployer l'infrastructure :

 ```bash
# 1. Authentification Azure:
    az login

# 2. Configuration de l'abonnement :
# Lancer la variable d'environnement depuis la racine du projet
    source .env

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

## Tag v2.1.0 : Configuration Management avec Ansible

Une fois l'infrastructure provisionnée par Terraform, la phase de **Configuration Management** intervient pour transformer des VMs vierges en serveurs fonctionnels. Cette étape est pilotée par Ansible.

### 1. Gestion des accès et sécurité
Pour garantir une automatisation fluide et sécurisée, l'approche suivante a été adoptée :
* **Authentification par Clé SSH** : Injection automatique de la clé publique locale via le module `authorized_key`. Cela permet de garantir l'accès même lorsque les politiques par défaut des images Azure restreignent l'usage des mots de passe.
* **Privilèges Sudo** : Configuration d'un accès `sudo` sans mot de passe pour les utilisateurs personnalisés, permettant à Ansible d'exécuter des tâches d'administration (apt, service) de manière totalement non-interactive.

### 2. Organisation par Rôles
Le déploiement est segmenté en rôles réutilisables pour respecter le principe **DRY** :
* **user_management** : Création des comptes utilisateurs, configuration des clés SSH et des droits sudoers.
* **web_server** : Installation de Nginx et déploiement d'une page d'accueil personnalisée.
* **admin_tools** : Installation d'outils de diagnostic réseau (nmap, tcpdump, netcat).

### 3. Orchestration Conditionnelle
Le playbook principal (`site.yml`) utilise des variables d'environnement et des conditions pour assigner des rôles spécifiques selon le nom d'hôte (`inventory_hostname`) :
* **VM-0** : Déployée comme serveur Web.
* **VM-1** : Déployée comme bastion d'administration.

---

## Guide d'utilisation Ansible

### Pré-requis locaux
Avant de lancer la configuration, assurez-vous d'avoir renseigné le fichier de variables d'environnement.

1. **Préparer le fichier .env** :
   Utilisez le template fourni pour créer votre fichier local (ce fichier est ignoré par Git pour votre sécurité) :

   ```bash
   cp .env.example .env
   # Éditez ensuite le fichier .env avec vos propres valeurs : ID abonnement, passwords, etc.
   ```

2. **Charger les credentials** :
   Au lieu d'exporter chaque variable manuellement, sourcez le fichier :
   ```bash
   source .env
   ```
### Exécution du Playbook
Depuis la racine du projet, lancez le déploiement de la configuration :

```bash
    cd ansible
    # Lancement du déploiement
    ansible-playbook site.yml
```

---

## État Actuel : Parc VM Multirôle Opérationnel
L'infrastructure est désormais complète et configurée :
- **Connectivité** : Toutes les machines sont accessibles via clé SSH.
- **Services** : Le serveur Web est en ligne et les outils d'administration sont prêts à l'emploi.
- **Orchestration** : Un seul point d'entrée (site.yml) permet de reconfigurer l'ensemble du parc de manière idempotente.

---

## Prochaines étapes

### 1. Collections & Optimisation
Migration des tâches vers des collections communautaires pour une meilleure maintenabilité.

### 2. Validation & Tests (Terratest)
Mise en place de tests unitaires et d'intégration avec **Terratest**. L'objectif est d'écrire des tests en Go pour valider automatiquement que :
- Les ressources Azure sont réellement créées selon le plan.
- Les ports (22, 80) sont bien ouverts.
- Les services (Nginx) répondent correctement après le passage d'Ansible.

### 3. Azure DevOps Pipeline
Intégration finale de l'exécution Ansible et des tests de validation dans le pipeline CI/CD pour un cycle de déploiement "Zero-Touch" et sécurisé.