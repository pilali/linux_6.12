#!/bin/bash
# Script pour extraire et adapter la configuration d'un système PatchboxOS existant

set -e

echo "=== Extraction de la configuration PatchboxOS ==="
echo ""
echo "Ce script vous aide à récupérer la configuration du noyau de votre"
echo "système PatchboxOS existant pour l'adapter au noyau 6.12."
echo ""

CONFIG_FILE=""
KERNEL_DIR="/kernel-build/linux-6.12"

# Vérification des arguments
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <chemin-vers-config-patchbox>"
    echo ""
    echo "Pour récupérer la config depuis votre Raspberry Pi PatchboxOS:"
    echo "1. Sur le Pi: sudo modprobe configs && zcat /proc/config.gz > /tmp/patchbox-config"
    echo "2. Copier le fichier /tmp/patchbox-config vers ce répertoire"
    echo "3. Lancer: $0 patchbox-config"
    echo ""
    echo "Alternative si /proc/config.gz n'existe pas:"
    echo "1. Sur le Pi: sudo find /boot -name 'config-*' -exec cp {} /tmp/patchbox-config \\;"
    echo "2. Copier le fichier vers ce répertoire"
    echo "3. Lancer: $0 patchbox-config"
    exit 1
fi

CONFIG_FILE="$1"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erreur: Fichier de configuration non trouvé: $CONFIG_FILE"
    exit 1
fi

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Erreur: Répertoire du noyau non trouvé: $KERNEL_DIR"
    echo "Assurez-vous d'avoir d'abord téléchargé les sources du noyau."
    exit 1
fi

echo "Configuration trouvée: $CONFIG_FILE"
echo "Répertoire du noyau: $KERNEL_DIR"
echo ""

cd "$KERNEL_DIR"

# Sauvegarde de la config actuelle
if [ -f ".config" ]; then
    cp .config .config.backup
    echo "Configuration actuelle sauvegardée dans .config.backup"
fi

# Copie de la configuration PatchboxOS
cp "$CONFIG_FILE" .config.patchbox.orig

echo "Adaptation de la configuration PatchboxOS au noyau 6.12..."

# Configuration de base avec la config PatchboxOS comme base
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- oldconfig < /dev/null

echo "Configuration adaptée avec succès."
echo ""
echo "Modifications recommandées pour optimiser le support des périphériques:"

# Application des optimisations spécifiques
echo "- Activation des patches RT..."
scripts/config --enable CONFIG_PREEMPT_RT

echo "- Optimisation du support Touch Display 2..."
scripts/config --enable CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN
scripts/config --enable CONFIG_TOUCHSCREEN_FT6236
scripts/config --enable CONFIG_BACKLIGHT_RPI

echo "- Optimisation du support audio Pisound..."
scripts/config --enable CONFIG_SND_USB_AUDIO
scripts/config --enable CONFIG_SND_USB_CAIAQ
scripts/config --enable CONFIG_SND_RAWMIDI

echo "- Optimisations Real-Time..."
scripts/config --set-val CONFIG_HZ 1000
scripts/config --enable CONFIG_HIGH_RES_TIMERS
scripts/config --enable CONFIG_NO_HZ_FULL

# Mise à jour finale de la configuration
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig

echo ""
echo "=== Configuration finale prête ==="
echo ""
echo "Fichiers créés:"
echo "- .config : Configuration finale optimisée"
echo "- .config.patchbox.orig : Configuration PatchboxOS originale"
echo "- .config.backup : Sauvegarde de la configuration précédente (si existante)"
echo ""
echo "Vous pouvez maintenant compiler avec: make compile"

# Affichage d'un résumé des options importantes
echo ""
echo "Options importantes activées:"
grep -E "(CONFIG_PREEMPT_RT|CONFIG_HZ|CONFIG_SND_|CONFIG_DRM_|CONFIG_TOUCHSCREEN_)" .config | head -20