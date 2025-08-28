#!/bin/bash

set -e

# Configuration
KERNEL_VERSION=${KERNEL_VERSION:-6.12.8}
RT_PATCH_VERSION=${RT_PATCH_VERSION:-6.12.8-rt25}
ARCH=${ARCH:-arm64}
CROSS_COMPILE=${CROSS_COMPILE:-aarch64-linux-gnu-}

# Répertoires
KERNEL_DIR="/workspace/kernel"
OUTPUT_DIR="/workspace/output"
CONFIGS_DIR="/workspace/configs"

echo "=== Compilation du noyau Linux $KERNEL_VERSION avec support RT ==="
echo "Architecture: $ARCH"
echo "Cross-compilateur: $CROSS_COMPILE"

# Création des répertoires
mkdir -p "$KERNEL_DIR" "$OUTPUT_DIR" "$CONFIGS_DIR"

cd "$KERNEL_DIR"

# Téléchargement du noyau Linux
if [ ! -d "linux-$KERNEL_VERSION" ]; then
    echo "Téléchargement du noyau Linux $KERNEL_VERSION..."
    wget -q "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz"
    tar -xf "linux-$KERNEL_VERSION.tar.xz"
    rm "linux-$KERNEL_VERSION.tar.xz"
fi

cd "linux-$KERNEL_VERSION"

# Téléchargement et application du patch RT
if [ ! -f "rt-patch-applied" ]; then
    echo "Téléchargement du patch RT $RT_PATCH_VERSION..."
    wget -q "https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.12/older/patch-$RT_PATCH_VERSION.patch"
    
    echo "Application du patch RT..."
    patch -p1 < "patch-$RT_PATCH_VERSION.patch"
    touch "rt-patch-applied"
    rm "patch-$RT_PATCH_VERSION.patch"
fi

# Configuration du noyau
echo "Configuration du noyau..."

# Copie de la configuration existante si disponible
if [ -f "$CONFIGS_DIR/.config" ]; then
    echo "Utilisation de la configuration existante..."
    cp "$CONFIGS_DIR/.config" .config
else
    echo "Génération d'une configuration par défaut..."
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig
fi

# Configuration spécifique pour Touch Display 2 et support audio
echo "Configuration des options spécifiques..."
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE menuconfig

# Sauvegarde de la configuration
cp .config "$CONFIGS_DIR/.config"

# Compilation du noyau
echo "Compilation du noyau..."
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE -j$(nproc)

# Compilation des modules
echo "Compilation des modules..."
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules -j$(nproc)

# Installation des modules
echo "Installation des modules..."
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules_install INSTALL_MOD_PATH="$OUTPUT_DIR"

# Copie des fichiers du noyau
echo "Copie des fichiers du noyau..."
cp arch/$ARCH/boot/Image "$OUTPUT_DIR/kernel-$KERNEL_VERSION-rt.img"
cp arch/$ARCH/boot/dts/broadcom/bcm2711-rpi-4-b.dts "$OUTPUT_DIR/"
cp arch/$ARCH/boot/dts/broadcom/bcm2711-rpi-4-b.dtb "$OUTPUT_DIR/"

# Génération du fichier de configuration
echo "Génération du fichier de configuration..."
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE savedefconfig
cp defconfig "$OUTPUT_DIR/config-$KERNEL_VERSION-rt"

echo "=== Compilation terminée avec succès! ==="
echo "Fichiers générés dans: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"