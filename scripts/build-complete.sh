#!/bin/bash

# Script principal pour la compilation complète du noyau
# avec support real-time et Touch Display 2

set -e

echo "=== Script de compilation complète du noyau Linux ==="
echo "Raspberry Pi 4 + DAC Pisound + Touch Display 2"
echo "Support real-time + Noyau 6.12+"
echo ""

# Vérification des prérequis
echo "Vérification des prérequis..."

# Vérification de la configuration PatchboxOS
if [ -f "./configs/patchbox-config" ]; then
    echo "✓ Configuration PatchboxOS trouvée"
    PATCHBOX_CONFIG="./configs/patchbox-config"
else
    echo "⚠ Configuration PatchboxOS non trouvée"
    echo "Exécutez d'abord le script extract-patchbox-config.sh sur votre Raspberry Pi"
    echo "Puis copiez le fichier avec: scp pi@<IP>:/tmp/patchbox-config ./configs/"
    exit 1
fi

# Vérification des répertoires
echo "Création des répertoires de travail..."
mkdir -p kernel output configs

# Étape 1: Configuration du support Touch Display 2
echo ""
echo "=== Étape 1: Configuration du support Touch Display 2 ==="
if [ -f "./scripts/configure-touch-display.sh" ]; then
    chmod +x ./scripts/configure-touch-display.sh
    ./scripts/configure-touch-display.sh "$PATCHBOX_CONFIG"
    echo "✓ Support Touch Display 2 configuré"
else
    echo "⚠ Script configure-touch-display.sh non trouvé"
    exit 1
fi

# Étape 2: Compilation du noyau
echo ""
echo "=== Étape 2: Compilation du noyau Linux 6.12+ avec support RT ==="
if [ -f "./scripts/build-kernel.sh" ]; then
    chmod +x ./scripts/build-kernel.sh
    
    # Vérification que nous sommes dans le conteneur Docker
    if [ -n "$DOCKER_CONTAINER" ] || [ -f "/.dockerenv" ]; then
        echo "✓ Environnement Docker détecté, lancement de la compilation..."
        ./scripts/build-kernel.sh
    else
        echo "⚠ Ce script doit être exécuté dans le conteneur Docker"
        echo "Lancez d'abord: docker-compose up -d"
        echo "Puis: docker-compose exec kernel-builder ./scripts/build-complete.sh"
        exit 1
    fi
else
    echo "⚠ Script build-kernel.sh non trouvé"
    exit 1
fi

# Étape 3: Fusion des configurations
echo ""
echo "=== Étape 3: Fusion des configurations ==="
if [ -f "./scripts/merge-configs.sh" ]; then
    chmod +x ./scripts/merge-configs.sh
    
    # Attendre que la compilation soit terminée et que .config soit généré
    if [ -f "./kernel/linux-6.12.8/.config" ]; then
        echo "✓ Configuration générée, fusion en cours..."
        ./scripts/merge-configs.sh "$PATCHBOX_CONFIG" "./kernel/linux-6.12.8/.config"
        echo "✓ Configurations fusionnées"
    else
        echo "⚠ Fichier .config non trouvé, compilation peut-être en cours..."
        echo "Relancez ce script après la fin de la compilation"
        exit 1
    fi
else
    echo "⚠ Script merge-configs.sh non trouvé"
    exit 1
fi

# Étape 4: Recompilation avec la configuration fusionnée
echo ""
echo "=== Étape 4: Recompilation avec la configuration fusionnée ==="
echo "Copie de la configuration fusionnée..."
cp "./kernel/linux-6.12.8/.config" "./configs/kernel-config-final"

echo "Recompilation du noyau avec la configuration fusionnée..."
cd "./kernel/linux-6.12.8"

# Nettoyage et recompilation
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules -j$(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH="../../output"

# Copie des fichiers finaux
echo "Copie des fichiers finaux..."
cp arch/arm64/boot/Image "../../output/kernel-6.12.8-rt-final.img"
cp arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb "../../output/"
cp .config "../../output/config-6.12.8-rt-final"

cd ../..

echo ""
echo "=== Compilation terminée avec succès! ==="
echo ""
echo "Fichiers générés dans ./output/:"
ls -la ./output/
echo ""
echo "Pour installer le nouveau noyau sur votre Raspberry Pi:"
echo "1. Copiez kernel-6.12.8-rt-final.img vers /boot/kernel8.img"
echo "2. Copiez bcm2711-rpi-4-b.dtb vers /boot/"
echo "3. Copiez le répertoire lib/modules vers /lib/modules/"
echo "4. Mettez à jour config.txt si nécessaire"
echo "5. Redémarrez votre Raspberry Pi"
echo ""
echo "Le nouveau noyau devrait reconnaître le Touch Display 2!"