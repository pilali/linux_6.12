# Script PowerShell pour la cross-compilation du noyau Linux 6.12+
# Raspberry Pi 4 + Touch Display 2 + Support Real-Time

param(
    [switch]$SkipConfigCheck,
    [switch]$AutoStart,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Usage: .\start-build.ps1 [Options]

Options:
    -SkipConfigCheck    Ignore la vérification de la configuration PatchboxOS
    -AutoStart         Lance automatiquement la compilation
    -Help              Affiche cette aide

Exemples:
    .\start-build.ps1                    # Vérification complète + démarrage manuel
    .\start-build.ps1 -SkipConfigCheck   # Ignore la vérification de config
    .\start-build.ps1 -AutoStart         # Lance automatiquement la compilation
"@
    exit 0
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Cross-compilation du noyau Linux 6.12+" -ForegroundColor Cyan
Write-Host " Raspberry Pi 4 + Touch Display 2 + RT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérification de Docker
Write-Host "Vérification de Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Host "✓ Docker détecté: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Docker non trouvé"
    }
} catch {
    Write-Host "❌ ERREUR: Docker n'est pas installé ou pas démarré" -ForegroundColor Red
    Write-Host "Veuillez installer Docker Desktop et le démarrer" -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour continuer"
    exit 1
}

# Vérification de la configuration PatchboxOS
if (-not $SkipConfigCheck) {
    if (-not (Test-Path "configs\patchbox-config")) {
        Write-Host "⚠ ATTENTION: Configuration PatchboxOS non trouvée" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Pour extraire la configuration depuis votre Raspberry Pi:" -ForegroundColor White
        Write-Host "1. Copiez le script: scp scripts\extract-patchbox-config.sh pi@<IP>:/tmp/" -ForegroundColor White
        Write-Host "2. Exécutez-le sur le Pi: /tmp/extract-patchbox-config.sh" -ForegroundColor White
        Write-Host "3. Copiez le résultat: scp pi@<IP>:/tmp/patchbox-config configs\" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Voulez-vous continuer sans la configuration PatchboxOS? (o/n)"
        if ($choice -ne "o" -and $choice -ne "O") {
            Write-Host "Compilation annulée" -ForegroundColor Yellow
            exit 0
        }
    } else {
        Write-Host "✓ Configuration PatchboxOS trouvée" -ForegroundColor Green
    }
}

# Construction de l'image Docker
Write-Host ""
Write-Host "Construction de l'image Docker..." -ForegroundColor Yellow
try {
    docker compose build
    if ($LASTEXITCODE -ne 0) {
        throw "Échec de la construction"
    }
    Write-Host "✓ Image Docker construite avec succès" -ForegroundColor Green
} catch {
    Write-Host "❌ ERREUR: Échec de la construction de l'image Docker" -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour continuer"
    exit 1
}

# Lancement du conteneur
Write-Host ""
Write-Host "Lancement du conteneur..." -ForegroundColor Yellow
try {
    docker compose up -d
    if ($LASTEXITCODE -ne 0) {
        throw "Échec du lancement"
    }
    Write-Host "✓ Conteneur lancé avec succès" -ForegroundColor Green
} catch {
    Write-Host "❌ ERREUR: Échec du lancement du conteneur" -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour continuer"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Environnement Docker prêt!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Affichage des commandes utiles
Write-Host "Commandes utiles:" -ForegroundColor White
Write-Host "• Accéder au conteneur: docker compose exec kernel-builder bash" -ForegroundColor Gray
Write-Host "• Voir les logs: docker compose logs kernel-builder" -ForegroundColor Gray
Write-Host "• Arrêter le conteneur: docker compose down" -ForegroundColor Gray
Write-Host ""

Write-Host "Pour lancer la compilation complète:" -ForegroundColor White
Write-Host "1. docker compose exec kernel-builder bash" -ForegroundColor Gray
Write-Host "2. ./scripts/build-complete.sh" -ForegroundColor Gray
Write-Host ""

Write-Host "Ou pour une compilation étape par étape:" -ForegroundColor White
Write-Host "1. ./scripts/configure-touch-display.sh ./configs/patchbox-config" -ForegroundColor Gray
Write-Host "2. ./scripts/build-kernel.sh" -ForegroundColor Gray
Write-Host "3. ./scripts/merge-configs.sh ./configs/patchbox-config ./kernel/linux-6.12.8/.config" -ForegroundColor Gray
Write-Host ""

# Lancement automatique si demandé
if ($AutoStart) {
    Write-Host "Lancement automatique de la compilation..." -ForegroundColor Yellow
    docker compose exec kernel-builder ./scripts/build-complete.sh
} else {
    $choice = Read-Host "Voulez-vous accéder au conteneur maintenant? (o/n)"
    if ($choice -eq "o" -or $choice -eq "O") {
        Write-Host "Ouverture du conteneur..." -ForegroundColor Yellow
        docker compose exec kernel-builder bash
    }
}

Write-Host ""
Write-Host "N'oubliez pas de copier les fichiers compilés depuis le conteneur:" -ForegroundColor White
Write-Host "docker cp kernel-builder:/workspace/output ./output-local" -ForegroundColor Gray