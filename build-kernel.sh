#!/bin/bash
set -e

# Configuration
KERNEL_VERSION="6.12"
RT_VERSION="6.12-rt10"
WORKSPACE="/kernel-build"
KERNEL_DIR="$WORKSPACE/linux-$KERNEL_VERSION"
OUTPUT_DIR="$WORKSPACE/output"

echo "=== Cross-compilation du noyau Linux $KERNEL_VERSION RT pour Raspberry Pi 4 ==="

# Création des répertoires
mkdir -p $OUTPUT_DIR

# Téléchargement du noyau Linux si nécessaire
if [ ! -d "$KERNEL_DIR" ]; then
    echo "Téléchargement du noyau Linux $KERNEL_VERSION..."
    cd $WORKSPACE
    wget -c https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
    tar -xf linux-$KERNEL_VERSION.tar.xz
fi

# Téléchargement des patches RT si nécessaire
RT_PATCH_FILE="patch-$RT_VERSION.patch.xz"
if [ ! -f "$WORKSPACE/$RT_PATCH_FILE" ]; then
    echo "Téléchargement des patches RT $RT_VERSION..."
    cd $WORKSPACE
    wget -c https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.12/$RT_PATCH_FILE
fi

# Application des patches RT
cd $KERNEL_DIR
if [ ! -f .rt_patched ]; then
    echo "Application des patches RT..."
    xzcat ../$RT_PATCH_FILE | patch -p1
    touch .rt_patched
fi

# Configuration de base pour Raspberry Pi 4 (ARM64)
echo "Configuration du noyau..."
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig

# Activation des options RT et autres optimisations
echo "Activation des options RT et optimisations audio..."
scripts/config --enable CONFIG_PREEMPT_RT
scripts/config --enable CONFIG_PREEMPT_RT_FULL
scripts/config --enable CONFIG_HIGH_RES_TIMERS
scripts/config --enable CONFIG_NO_HZ
scripts/config --enable CONFIG_NO_HZ_IDLE
scripts/config --enable CONFIG_HRTIMERS
scripts/config --enable CONFIG_IRQ_FORCED_THREADING

# Support audio avancé
scripts/config --enable CONFIG_SND
scripts/config --enable CONFIG_SND_BCM2835
scripts/config --enable CONFIG_SND_USB_AUDIO
scripts/config --enable CONFIG_SND_USB_CAIAQ
scripts/config --enable CONFIG_SND_RAWMIDI
scripts/config --enable CONFIG_SND_SEQUENCER

# Support écran tactile Raspberry Pi Touch Display 2
scripts/config --enable CONFIG_DRM
scripts/config --enable CONFIG_DRM_VC4
scripts/config --enable CONFIG_DRM_VC4_HDMI_CEC
scripts/config --enable CONFIG_FB_SIMPLE
scripts/config --enable CONFIG_BACKLIGHT_CLASS_DEVICE
scripts/config --enable CONFIG_BACKLIGHT_RPI

# Support tactile
scripts/config --enable CONFIG_INPUT_TOUCHSCREEN
scripts/config --enable CONFIG_TOUCHSCREEN_FT6236
scripts/config --enable CONFIG_TOUCHSCREEN_GOODIX
scripts/config --enable CONFIG_HID_MULTITOUCH

# Support I2C et SPI
scripts/config --enable CONFIG_I2C
scripts/config --enable CONFIG_I2C_BCM2835
scripts/config --enable CONFIG_SPI
scripts/config --enable CONFIG_SPI_BCM2835
scripts/config --enable CONFIG_SPI_BCM2835AUX

# Support GPIO
scripts/config --enable CONFIG_GPIOLIB
scripts/config --enable CONFIG_GPIO_SYSFS

# Compilation
echo "Compilation du noyau..."
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)

# Compilation des modules
echo "Compilation des modules..."
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules -j$(nproc)

# Installation des modules dans le répertoire de sortie
echo "Installation des modules..."
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=$OUTPUT_DIR modules_install

# Copie des fichiers importants
echo "Copie des fichiers de sortie..."
cp arch/arm64/boot/Image $OUTPUT_DIR/
cp arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb $OUTPUT_DIR/

# Création du répertoire boot
mkdir -p $OUTPUT_DIR/boot

# Copie dans le format attendu par le Pi
cp arch/arm64/boot/Image $OUTPUT_DIR/boot/kernel8.img

echo "=== Compilation terminée ==="
echo "Fichiers de sortie disponibles dans: $OUTPUT_DIR"
echo "- kernel8.img: Image du noyau"
echo "- bcm2711-rpi-4-b.dtb: Device Tree Blob"
echo "- lib/modules/$KERNEL_VERSION*: Modules du noyau"