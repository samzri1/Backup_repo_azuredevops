# Script PowerShell pour lister les projets et cloner les dépôts Git dans Azure DevOps

Ce script permet d'interagir avec l'API d'Azure DevOps pour :

1. Lister les projets disponibles dans différentes organisations.
2. Télécharger les informations des dépôts Git associés à chaque projet.
3. Cloner les dépôts Git localement, en organisant les résultats par dossiers.

## Prérequis

Avant d'exécuter ce script, assurez-vous d'avoir :

1. **PowerShell** installé.
2. **Git** installé sur votre machine.
3. Les **tokens d'accès Azure DevOps** valides pour chaque organisation.
4. Des permissions suffisantes pour accéder aux projets et dépôts des organisations listées.

## Configuration

Le script utilise une liste d'organisations et leurs tokens correspondants. Modifiez la variable `$organizations` pour y inclure vos propres informations :

```powershell
$organizations = @(
    @{ Name = "NomOrganisation1"; Token = "VotreToken1" },
    @{ Name = "NomOrganisation2"; Token = "VotreToken2" }
)
```

Remplacez `{{VotreToken1}}`, etc., par les tokens d'accès personnels (PAT) de vos organisations.

## Fonctionnalités

1. **Récupération des projets** : Pour chaque organisation, le script utilise l'API Azure DevOps pour récupérer une liste de projets, qui est enregistrée dans un fichier `projets.json` dans un dossier spécifique à l'organisation.

2. **Organisation des projets** : Chaque projet est sauvegardé dans un dossier portant son nom, avec des sous-dossiers dédiés aux dépôts Git.

3. **Récupération des dépôts Git** : Les informations des dépôts Git de chaque projet sont enregistrées dans un fichier `repo_definitions.json`.

4. **Clonage des dépôts Git** : Les dépôts sont clonés localement, et les erreurs éventuelles sont journalisées.

## Structure des dossiers

Le script organise les fichiers et dossiers comme suit :

```
Workspace/
└── Organisation1/
    ├── projets.json
    ├── Project1/
    │   ├── build/
    │   │   └── repo_definitions.json
    │   └── repo_groups/
    │       └── Repository1/
    └── Project2/
        ├── build/
        └── repo_groups/
```

## Exécution

Pour exécuter le script, ouvrez une console PowerShell, placez-vous dans le répertoire contenant le script et exécutez-le avec :

```powershell
.\script.ps1
```

## Points importants

1. **Gestion des caractères non valides** : Les noms de projets et de dépôts sont nettoyés pour éviter les problèmes avec les noms de fichiers ou de dossiers.
2. **Authentification** : Le script encode les tokens en base64 pour les inclure dans les en-têtes HTTP.
3. **Journalisation** : Les erreurs rencontrées lors du clonage des dépôts sont enregistrées dans un fichier `clone_log.txt`.

## Dépannage

- **Erreur de clonage** : Vérifiez le contenu du fichier `clone_log.txt` généré pour identifier les problèmes.
- **Permissions insuffisantes** : Assurez-vous que les tokens ont les permissions nécessaires pour accéder aux projets et dépôts.

---

```
