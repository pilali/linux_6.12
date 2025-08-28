@echo off
echo ========================================
echo  Cross-compilation du noyau Linux 6.12+
echo  Raspberry Pi 4 + Touch Display 2 + RT
echo ========================================
echo.

REM Vérification de Docker
echo Vérification de Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERREUR: Docker n'est pas installé ou pas démarré
    echo Veuillez installer Docker Desktop et le démarrer
    pause
    exit /b 1
)

REM Vérification de la configuration PatchboxOS
if not exist "configs\patchbox-config" (
    echo ATTENTION: Configuration PatchboxOS non trouvée
    echo.
    echo Pour extraire la configuration depuis votre Raspberry Pi:
    echo 1. Copiez le script: scp scripts\extract-patchbox-config.sh pi@^<IP^>:/tmp/
    echo 2. Exécutez-le sur le Pi: /tmp/extract-patchbox-config.sh
    echo 3. Copiez le résultat: scp pi@^<IP^>:/tmp/patchbox-config configs\
    echo.
    echo Voulez-vous continuer sans la configuration PatchboxOS? (o/n)
    set /p choice=
    if /i "%choice%" neq "o" (
        echo Compilation annulée
        pause
        exit /b 1
    )
)

echo.
echo Construction de l'image Docker...
docker compose build

if %errorlevel% neq 0 (
    echo ERREUR: Échec de la construction de l'image Docker
    pause
    exit /b 1
)

echo.
echo Lancement du conteneur...
docker compose up -d

if %errorlevel% neq 0 (
    echo ERREUR: Échec du lancement du conteneur
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Environnement Docker prêt!
echo ========================================
echo.
echo Pour accéder au conteneur et lancer la compilation:
echo   docker compose exec kernel-builder bash
echo.
echo Puis dans le conteneur:
echo   ./scripts/build-complete.sh
echo.
echo Ou pour une compilation étape par étape:
echo   1. ./scripts/configure-touch-display.sh ./configs/patchbox-config
echo   2. ./scripts/build-kernel.sh
echo   3. ./scripts/merge-configs.sh ./configs/patchbox-config ./kernel/linux-6.12.8/.config
echo.
echo Appuyez sur une touche pour continuer...
pause >nul

REM Ouverture du conteneur directement
echo.
echo Ouverture du conteneur...
docker compose exec kernel-builder bash