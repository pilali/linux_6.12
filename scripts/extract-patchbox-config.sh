#!/bin/bash

set -e

echo "=== Extraction de la configuration PatchboxOS ==="

# Vérification de la présence de la carte SD
if [ ! -d "/media/patchbox" ]; then
    echo "Erreur: Carte SD PatchboxOS non montée"
    echo "Veuillez monter la carte SD dans /media/patchbox"
    exit 1
fi

PATCHBOX_ROOT="/media/patchbox"
CONFIG_DIR="$PATCHBOX_ROOT/boot"
OUTPUT_DIR="configs"

mkdir -p $OUTPUT_DIR

echo "Recherche des fichiers de configuration..."

# Recherche du fichier de configuration du noyau
if [ -f "$CONFIG_DIR/config.txt" ]; then
    echo "Copie de config.txt..."
    cp "$CONFIG_DIR/config.txt" "$OUTPUT_DIR/"
fi

# Recherche du fichier cmdline.txt
if [ -f "$CONFIG_DIR/cmdline.txt" ]; then
    echo "Copie de cmdline.txt..."
    cp "$CONFIG_DIR/cmdline.txt" "$OUTPUT_DIR/"
fi

# Recherche des overlays DTB
if [ -d "$CONFIG_DIR/overlays" ]; then
    echo "Copie des overlays DTB..."
    cp -r "$CONFIG_DIR/overlays" "$OUTPUT_DIR/"
fi

# Recherche du fichier de configuration du noyau compilé
if [ -f "$CONFIG_DIR/config-$(uname -r)" ]; then
    echo "Copie de la configuration du noyau..."
    cp "$CONFIG_DIR/config-$(uname -r)" "$OUTPUT_DIR/kernel-config"
fi

# Recherche des modules chargés
echo "Extraction des modules chargés..."
lsmod > "$OUTPUT_DIR/loaded-modules.txt"

# Recherche des périphériques USB
echo "Extraction des périphériques USB..."
lsusb > "$OUTPUT_DIR/usb-devices.txt"

# Recherche des périphériques I2C
echo "Extraction des périphériques I2C..."
if command -v i2cdetect &> /dev/null; then
    i2cdetect -y 1 > "$OUTPUT_DIR/i2c-devices.txt" 2>/dev/null || true
fi

# Recherche des périphériques SPI
echo "Extraction des périphériques SPI..."
ls /dev/spidev* > "$OUTPUT_DIR/spi-devices.txt" 2>/dev/null || true

echo "=== Extraction terminée ==="
echo "Fichiers extraits dans le répertoire $OUTPUT_DIR/"
echo ""
echo "Contenu du répertoire:"
ls -la $OUTPUT_DIR/