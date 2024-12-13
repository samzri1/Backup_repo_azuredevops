# Définir une liste d'organisations et leurs tokens respectifs
$organizations = @(
    @{ Name = "NomOrganisation1"; Token = "{{VotreToken1}}" },
    @{ Name = "NomOrganisation2"; Token = "{{VotreToken2}}" },
  
)


# Boucler sur chaque organisation
foreach ($org in $organizations) {
    $organization = $org.Name
    $token = $org.Token

    # Convertir le token en base64
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $token)))

    # Définir les en-têtes de la requête
    $headers = @{
        Authorization = ("Basic {0}" -f $base64AuthInfo)
        Accept = "application/json"
    }

    # Définir l'URL de l'API pour lister les projets
    $projectsUrl = "https://dev.azure.com/$organization/_apis/projects?api-version=7.1"

    # Effectuer la requête GET pour obtenir la liste des projets
    $projectsResponse = Invoke-RestMethod -Uri $projectsUrl -Method Get -Headers $headers

    # Créer un dossier pour l'organisation
    $orgFolder = "$organization"
    if (-Not (Test-Path -Path $orgFolder)) {
        New-Item -ItemType Directory -Path $orgFolder
    }

    # Enregistrer le résultat dans un fichier JSON dans le dossier de l'organisation
    $projectsResponse | ConvertTo-Json -Depth 10 | Out-File -FilePath "$orgFolder/projets.json" -Encoding utf8



    Write-Output "La liste des projets pour l'organisation '$organization' a été enregistrée dans $orgFolder/projets.json"



    # Boucler sur chaque projet et effectuer les opérations nécessaires
    foreach ($project in $projectsResponse.value) {
        $projectName = $project.name -replace '[^a-zA-Z0-9_-]', '_'  # Remplacer les caractères non valides pour les noms de dossiers
        $projectId = $project.id

        # Créer un dossier pour le projet
        $projectFolder = "$orgFolder/$projectName"
        if (-Not (Test-Path -Path $projectFolder)) {
            New-Item -ItemType Directory -Path $projectFolder
        }

        # Créer des dossiers pour les pipelines de build, de release et les task groups
        $buildFolder = "$projectFolder/build"
        
        
        $repoFolder = "$projectFolder/repo_groups"
        if (-Not (Test-Path -Path $buildFolder)) {
            New-Item -ItemType Directory -Path $buildFolder
        }
     
        if (-Not (Test-Path -Path $repoFolder)) {
            New-Item -ItemType Directory -Path $repoFolder
        }


        # Definir l'URL de l'API pour obtenir les definitions de build du projet
        $buildDefinitionsUrl = "https://dev.azure.com/$organization/$projectId/_apis/git/repositories?api-version=7.1"

        # Effectuer la requete GET pour obtenir les definitions de build du projet
        $buildDefinitionsResponse = Invoke-RestMethod -Uri $buildDefinitionsUrl -Method Get -Headers $headers

        # Enregistrer le resultat dans un fichier JSON dans le dossier de build
       $buildDefinitionsResponse | ConvertTo-Json -Depth 10 | Out-File -FilePath "$buildFolder/repo_definitions.json" -Encoding utf8


        Write-Output "Les definitions de build pour le projet '$projectName' ont ete enregistrees dans $buildFolder/build_definitions.json"

        # Lire le fichier JSON pour extraire les IDs des definitions de build
        $buildDefinitionsContent = Get-Content -Path "$buildFolder/repo_definitions.json" | ConvertFrom-Json

         foreach ($definition in $buildDefinitionsContent.value) {
            $remoteUrl = $definition.remoteUrl
            $name = $definition.name -replace '[^a-zA-Z0-9_-]', '_'
            
            # Vérifiez et encodez les espaces dans l'URL
            $remoteUrl = $remoteUrl -replace ' ', '%20'
        
           
           # Remplacer l'organisation actuelle par le token
            $remoteUrlWithToken = $remoteUrl -replace "^https://$organization@", "https://$token@"
        
        
            # Construire le chemin local
            $nameFormated = "$name" -replace '[^a-zA-Z0-9_\-\\]', '_'
            $repoClonePath = "$repoFolder/$nameFormated"
        
            Write-Output "Cloning repository: $remoteUrlWithToken into $repoClonePath"
            
            # Créer le répertoire s'il n'existe pas
            if (-Not (Test-Path -Path $repoClonePath)) {
                New-Item -ItemType Directory -Path $repoClonePath | Out-Null
            }
        
            # Clonage avec journalisation
            try {
                git clone "$remoteUrlWithToken" "$repoClonePath" > clone_log.txt 2>&1
                Write-Output "Repository cloned successfully into $repoClonePath"
            } catch {
                Write-Output "Error cloning repository: $name"
                Write-Output $_
                Get-Content clone_log.txt
            }
       }

  }
