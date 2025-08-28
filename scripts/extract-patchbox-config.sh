#!/bin/bash

# Script pour extraire la configuration du noyau PatchboxOS
# À exécuter sur le Raspberry Pi PatchboxOS

set -e

echo "=== Extraction de la configuration du noyau PatchboxOS ==="

# Vérification que nous sommes sur un Raspberry Pi
if [ ! -f "/proc/device-tree/model" ]; then
    echo "Erreur: Ce script doit être exécuté sur un Raspberry Pi"
    exit 1
fi

# Lecture du modèle
MODEL=$(tr -d '\0' < /proc/device-tree/model)
echo "Modèle détecté: $MODEL"

# Vérification de la version du noyau
KERNEL_VERSION=$(uname -r)
echo "Version du noyau actuel: $KERNEL_VERSION"

# Vérification du support RT
if [ -f "/sys/kernel/realtime" ]; then
    echo "Support RT détecté: OUI"
else
    echo "Support RT détecté: NON"
fi

# Extraction de la configuration du noyau
echo "Extraction de la configuration du noyau..."
if [ -f "/proc/config.gz" ]; then
    echo "Configuration compressée détectée, décompression..."
    zcat /proc/config.gz > /tmp/patchbox-config
    echo "Configuration extraite dans /tmp/patchbox-config"
elif [ -f "/boot/config-$KERNEL_VERSION" ]; then
    echo "Configuration trouvée dans /boot/"
    cp "/boot/config-$KERNEL_VERSION" /tmp/patchbox-config
else
    echo "Aucune configuration trouvée, tentative de génération..."
    # Tentative de génération de la configuration
    if command -v modprobe >/dev/null 2>&1; then
        modprobe configs
        if [ -f "/proc/config.gz" ]; then
            zcat /proc/config.gz > /tmp/patchbox-config
            echo "Configuration générée dans /tmp/patchbox-config"
        else
            echo "Impossible de générer la configuration"
            exit 1
        fi
    else
        echo "Impossible de générer la configuration"
        exit 1
    fi
fi

# Vérification des modules audio et touch
echo "Vérification des modules audio..."
AUDIO_MODULES=$(find /lib/modules/$KERNEL_VERSION -name "*snd*" -o -name "*audio*" -o -name "*sound*" | head -10)
echo "Modules audio trouvés:"
echo "$AUDIO_MODULES"

echo "Vérification des modules touch..."
TOUCH_MODULES=$(find /lib/modules/$KERNEL_VERSION -name "*touch*" -o -name "*input*" -o -name "*hid*" | head -10)
echo "Modules touch trouvés:"
echo "$TOUCH_MODULES"

# Vérification des périphériques USB
echo "Périphériques USB détectés:"
lsusb

# Vérification des périphériques d'entrée
echo "Périphériques d'entrée détectés:"
ls /dev/input/ 2>/dev/null || echo "Aucun périphérique d'entrée trouvé"

# Vérification des modules chargés
echo "Modules chargés:"
lsmod | head -20

echo ""
echo "=== Extraction terminée ==="
echo "Configuration sauvegardée dans: /tmp/patchbox-config"
echo "Copiez ce fichier vers votre PC pour l'utiliser avec le script de compilation"
echo ""
echo "Pour copier le fichier depuis votre PC:"
echo "scp pi@<IP_RASPBERRY>:/tmp/patchbox-config ./configs/patchbox-config"