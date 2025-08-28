#!/bin/bash

echo "=== Nettoyage de l'environnement de compilation ==="

# Nettoyage des sources du noyau
if [ -d "kernel" ]; then
    echo "Nettoyage des sources du noyau..."
    cd kernel
    
    # Nettoyage des sources Linux
    if [ -d "linux-${KERNEL_VERSION:-6.12.8}" ]; then
        echo "  Nettoyage de linux-${KERNEL_VERSION:-6.12.8}..."
        cd "linux-${KERNEL_VERSION:-6.12.8}"
        make clean
        cd ..
    fi
    
    # Suppression des archives téléchargées
    echo "  Suppression des archives..."
    rm -f linux-*.tar.xz
    rm -f rt-patch-*.patch
    rm -rf patches-*
    
    # Suppression des firmwares (optionnel)
    if [ -d "rpi-firmware" ]; then
        echo "  Suppression des firmwares RPi..."
        rm -rf rpi-firmware
    fi
    
    cd ..
fi

# Nettoyage des modules compilés
if [ -d "output/lib/modules" ]; then
    echo "Nettoyage des modules compilés..."
    rm -rf output/lib/modules
fi

# Nettoyage des fichiers temporaires
echo "Nettoyage des fichiers temporaires..."
find . -name "*.tmp" -delete
find . -name "*.o" -delete
find . -name "*.ko" -delete

echo "=== Nettoyage terminé ==="
echo "Espace libéré. Vous pouvez relancer la compilation si nécessaire."