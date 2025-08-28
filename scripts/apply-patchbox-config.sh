#!/bin/bash

set -e

echo "=== Application de la configuration PatchboxOS ==="

KERNEL_DIR="kernel/linux-${KERNEL_VERSION:-6.12.8}"
CONFIG_DIR="configs"

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Erreur: Répertoire du noyau $KERNEL_DIR non trouvé"
    exit 1
fi

cd "$KERNEL_DIR"

# Application de la configuration de base
if [ -f "../../$CONFIG_DIR/kernel-config" ]; then
    echo "Application de la configuration du noyau PatchboxOS..."
    cp "../../$CONFIG_DIR/kernel-config" .config
else
    echo "Configuration du noyau non trouvée, utilisation de la configuration par défaut..."
    make bcm2711_defconfig
fi

# Activation des options Touch Display 2
echo "Activation des options Touch Display 2..."
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
./scripts/config --enable CONFIG_TOUCHSCREEN_MTK
./scripts/config --enable CONFIG_TOUCHSCREEN_PIXCIR
./scripts/config --enable CONFIG_TOUCHSCREEN_S6SY761
./scripts/config --enable CONFIG_TOUCHSCREEN_SURFACE3_SPI
./scripts/config --enable CONFIG_TOUCHSCREEN_TOUCHIT213
./scripts/config --enable CONFIG_TOUCHSCREEN_TSC_SERIO
./scripts/config --enable CONFIG_TOUCHSCREEN_TSC2005
./scripts/config --enable CONFIG_TOUCHSCREEN_WM831X
./scripts/config --enable CONFIG_TOUCHSCREEN_WM9705
./scripts/config --enable CONFIG_TOUCHSCREEN_WM9712
./scripts/config --enable CONFIG_TOUCHSCREEN_WM9713

# Options RT
./scripts/config --enable CONFIG_PREEMPT_RT
./scripts/config --enable CONFIG_HIGH_RES_TIMERS
./scripts/config --enable CONFIG_NO_HZ_FULL
./scripts/config --enable CONFIG_CPU_ISOLATION

# Options audio pour Pisound
./scripts/config --enable CONFIG_SND_BCM2708_SOC_PISOUND
./scripts/config --enable CONFIG_SND_BCM2708_SOC_PISOUND_ADC
./scripts/config --enable CONFIG_SND_BCM2708_SOC_PISOUND_DAC

echo "Configuration appliquée avec succès!"
echo "Vous pouvez maintenant compiler le noyau avec 'make -j$(nproc) Image modules dtbs'"