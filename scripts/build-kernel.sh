#!/bin/bash

set -e

# Configuration
KERNEL_VERSION=${KERNEL_VERSION:-6.12.8}
RT_PATCH_VERSION=${RT_PATCH_VERSION:-6.12.8-rt25}
RPI_FIRMWARE_VERSION="1.20231025"
RPI_KERNEL_VERSION="1.20231025"

echo "=== Compilation du noyau Linux $KERNEL_VERSION avec support RT ==="

# Téléchargement des sources du noyau
if [ ! -d "kernel/linux-$KERNEL_VERSION" ]; then
    echo "Téléchargement du noyau Linux $KERNEL_VERSION..."
    cd kernel
    wget -O linux-$KERNEL_VERSION.tar.xz https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
    tar -xf linux-$KERNEL_VERSION.tar.xz
    cd ..
fi

# Téléchargement du patch RT
if [ ! -f "kernel/rt-patch-$RT_PATCH_VERSION.patch" ]; then
    echo "Téléchargement du patch RT $RT_PATCH_VERSION..."
    cd kernel
    wget -O rt-patch-$RT_PATCH_VERSION.patch https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.12/older/patches-$RT_PATCH_VERSION.tar.xz
    tar -xf patches-$RT_PATCH_VERSION.tar.xz
    mv patches-$RT_PATCH_VERSION/*.patch rt-patch-$RT_PATCH_VERSION.patch
    cd ..
fi

# Téléchargement des firmwares Raspberry Pi
if [ ! -d "kernel/rpi-firmware" ]; then
    echo "Téléchargement des firmwares Raspberry Pi..."
    cd kernel
    git clone --depth 1 --branch $RPI_FIRMWARE_VERSION https://github.com/raspberrypi/firmware.git rpi-firmware
    cd ..
fi

# Application du patch RT
echo "Application du patch RT..."
cd kernel/linux-$KERNEL_VERSION
patch -p1 < ../rt-patch-$RT_PATCH_VERSION.patch

# Configuration du noyau
echo "Configuration du noyau..."
make bcm2711_defconfig

# Activation des options nécessaires pour le Touch Display 2 et RT
echo "Activation des options Touch Display 2 et RT..."
./scripts/config --enable CONFIG_TOUCHSCREEN_ADS7846
./scripts/config --enable CONFIG_TOUCHSCREEN_GOODIX
./scripts/config --enable CONFIG_TOUCHSCREEN_ILI210X
./scripts/config --enable CONFIG_TOUCHSCREEN_EDT_FT5X06
./scripts/config --enable CONFIG_TOUCHSCREEN_STMPE
./scripts/config --enable CONFIG_TOUCHSCREEN_TSC2007
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX
./scripts/config --enable CONFIG_TOUCHSCREEN_USB_COMPOSITE
./scripts/config --enable CONFIG_TOUCHSCREEN_ATMEL_MXT
./scripts/config --enable CONFIG_TOUCHSCREEN_SYNAPTICS_DSX
./scripts/config --enable CONFIG_TOUCHSCREEN_ELAN
./scripts/config --enable CONFIG_TOUCHSCREEN_GT9XX
./scripts/config --enable CONFIG_TOUCHSCREEN_ILI210X
./scripts/config --enable CONFIG_TOUCHSCREEN_MTK
./scripts/config --enable CONFIG_TOUCHSCREEN_PIXCIR
./scripts/config --enable CONFIG_TOUCHSCREEN_S6SY761
./scripts/config --enable CONFIG_TOUCHSCREEN_SURFACE3_SPI
./scripts/config --enable CONFIG_TOUCHSCREEN_TOUCHIT213
./scripts/config --enable CONFIG_TOUCHSCREEN_TSC_SERIO
./scripts/config --enable CONFIG_TOUCHSCREEN_TSC2005
./scripts/config --enable CONFIG_TOUCHSCREEN_TSC2007
./scripts/config --enable CONFIG_TOUCHSCREEN_WM831X
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX
./scripts/config --enable CONFIG_TOUCHSCREEN_WM9705
./scripts/config --enable CONFIG_TOUCHSCREEN_WM9712
./scripts/config --enable CONFIG_TOUCHSCREEN_WM9713
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_MAINSTONE
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_ZYLONITE
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_TOUCH
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_IRQ
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_SPI
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_I2C
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_AC97
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_IRQ
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_SPI
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_I2C
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_AC97
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_IRQ_SPI
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_IRQ_I2C
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_IRQ_AC97
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_SPI_I2C
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_SPI_AC97
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_I2C_AC97
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_IRQ_SPI_I2C
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_IRQ_SPI_AC97
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_IRQ_I2C_AC97
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_SPI_I2C_AC97
./scripts/config --enable CONFIG_TOUCHSCREEN_WM97XX_GPIO_IRQ_SPI_I2C_AC97

# Options RT
./scripts/config --enable CONFIG_PREEMPT_RT
./scripts/config --enable CONFIG_HIGH_RES_TIMERS
./scripts/config --enable CONFIG_NO_HZ_FULL
./scripts/config --enable CONFIG_CPU_ISOLATION

# Compilation
echo "Compilation du noyau..."
make -j$(nproc) Image modules dtbs

# Installation des modules
echo "Installation des modules..."
make modules_install INSTALL_MOD_PATH=../../output

# Copie des fichiers de sortie
echo "Copie des fichiers de sortie..."
cp arch/arm64/boot/Image ../../output/
cp arch/arm64/boot/dts/broadcom/*.dtb ../../output/
cp arch/arm64/boot/dts/overlays/*.dtbo ../../output/

echo "=== Compilation terminée avec succès! ==="
echo "Fichiers générés dans le répertoire output/"