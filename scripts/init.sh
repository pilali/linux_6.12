#!/bin/bash

# Script d'initialisation pour l'environnement de cross-compilation
echo "=== Configuration de l'environnement de cross-compilation ==="
echo "Architecture: $ARCH"
echo "Cross-compilateur: $CROSS_COMPILE"
echo "Version du noyau: $KERNEL_VERSION"
echo "Version du patch RT: $RT_PATCH_VERSION"

# Vérification des variables d'environnement
if [ -z "$ARCH" ] || [ -z "$CROSS_COMPILE" ]; then
    echo "Erreur: Variables d'environnement ARCH et CROSS_COMPILE non définies"
    exit 1
fi

# Configuration des variables d'environnement pour la compilation
export ARCH=$ARCH
export CROSS_COMPILE=$CROSS_COMPILE
export KERNEL_VERSION=$KERNEL_VERSION
export RT_PATCH_VERSION=$RT_PATCH_VERSION

# Ajout du cross-compilateur au PATH
export PATH="/usr/bin:$PATH"

echo "Environnement configuré avec succès!"
echo "Utilisez 'make help' dans le répertoire kernel pour voir les options disponibles"
echo ""

# Exécution de la commande passée en argument
exec "$@"