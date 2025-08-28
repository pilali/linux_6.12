#!/bin/bash

set -e

echo "=== Déploiement du nouveau noyau sur la carte SD ==="

# Vérification des paramètres
if [ $# -ne 1 ]; then
    echo "Usage: $0 <chemin_vers_carte_sd>"
    echo "Exemple: $0 /media/patchbox"
    exit 1
fi

PATCHBOX_ROOT="$1"
OUTPUT_DIR="output"

if [ ! -d "$PATCHBOX_ROOT" ]; then
    echo "Erreur: Répertoire $PATCHBOX_ROOT non trouvé"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Erreur: Répertoire de sortie $OUTPUT_DIR non trouvé"
    exit 1
fi

echo "Déploiement sur: $PATCHBOX_ROOT"

# Sauvegarde de l'ancien noyau
echo "Sauvegarde de l'ancien noyau..."
BACKUP_DIR="$PATCHBOX_ROOT/boot/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "$PATCHBOX_ROOT/boot/Image" ]; then
    cp "$PATCHBOX_ROOT/boot/Image" "$BACKUP_DIR/"
fi

if [ -d "$PATCHBOX_ROOT/boot/overlays" ]; then
    cp -r "$PATCHBOX_ROOT/boot/overlays" "$BACKUP_DIR/"
fi

# Copie du nouveau noyau
echo "Copie du nouveau noyau..."
if [ -f "$OUTPUT_DIR/Image" ]; then
    cp "$OUTPUT_DIR/Image" "$PATCHBOX_ROOT/boot/"
    echo "  ✓ Noyau copié"
else
    echo "  ✗ Fichier Image non trouvé"
    exit 1
fi

# Copie des overlays DTB
if [ -d "$OUTPUT_DIR/overlays" ]; then
    cp -r "$OUTPUT_DIR/overlays" "$PATCHBOX_ROOT/boot/"
    echo "  ✓ Overlays DTB copiés"
fi

# Copie des modules
if [ -d "$OUTPUT_DIR/lib/modules" ]; then
    MODULE_VERSION=$(ls "$OUTPUT_DIR/lib/modules/" | head -n1)
    if [ -n "$MODULE_VERSION" ]; then
        # Suppression de l'ancienne version des modules
        if [ -d "$PATCHBOX_ROOT/lib/modules/$MODULE_VERSION" ]; then
            rm -rf "$PATCHBOX_ROOT/lib/modules/$MODULE_VERSION"
        fi
        
        # Copie de la nouvelle version
        cp -r "$OUTPUT_DIR/lib/modules/$MODULE_VERSION" "$PATCHBOX_ROOT/lib/modules/"
        echo "  ✓ Modules copiés (version: $MODULE_VERSION)"
    fi
fi

# Mise à jour de config.txt
echo "Mise à jour de config.txt..."
if [ -f "$PATCHBOX_ROOT/boot/config.txt" ]; then
    # Sauvegarde
    cp "$PATCHBOX_ROOT/boot/config.txt" "$BACKUP_DIR/"
    
    # Ajout de la configuration pour le Touch Display 2
    if ! grep -q "dtoverlay=ads7846" "$PATCHBOX_ROOT/boot/config.txt"; then
        echo "" >> "$PATCHBOX_ROOT/boot/config.txt"
        echo "# Touch Display 2 support" >> "$PATCHBOX_ROOT/boot/config.txt"
        echo "dtoverlay=ads7846,penirq=25,penirq_pull=2,speed=50000,keep_vref_on=0,swapxy=0,pmax=255,xohms=150,xmin=200,xmax=3900,ymin=200,ymax=3900" >> "$PATCHBOX_ROOT/boot/config.txt"
        echo "  ✓ Configuration Touch Display 2 ajoutée"
    fi
fi

echo ""
echo "=== Déploiement terminé avec succès! ==="
echo "Sauvegarde créée dans: $BACKUP_DIR"
echo ""
echo "Prochaines étapes:"
echo "1. Démonter la carte SD proprement"
echo "2. Redémarrer le Raspberry Pi"
echo "3. Vérifier que le Touch Display 2 fonctionne"
echo "4. Vérifier la latence audio avec le noyau RT"