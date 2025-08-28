#!/bin/bash

set -e

echo "=== Vérification de la reconnaissance du Touch Display 2 ==="

KERNEL_DIR="kernel/linux-${KERNEL_VERSION:-6.12.8}"

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Erreur: Répertoire du noyau $KERNEL_DIR non trouvé"
    exit 1
fi

cd "$KERNEL_DIR"

# Vérification de la configuration
echo "Vérification de la configuration du noyau..."

# Vérification des options Touch Display
TOUCH_OPTIONS=(
    "CONFIG_TOUCHSCREEN_ADS7846"
    "CONFIG_TOUCHSCREEN_GOODIX"
    "CONFIG_TOUCHSCREEN_ILI210X"
    "CONFIG_TOUCHSCREEN_EDT_FT5X06"
    "CONFIG_TOUCHSCREEN_STMPE"
    "CONFIG_TOUCHSCREEN_TSC2007"
    "CONFIG_TOUCHSCREEN_WM97XX"
    "CONFIG_TOUCHSCREEN_USB_COMPOSITE"
    "CONFIG_TOUCHSCREEN_ATMEL_MXT"
    "CONFIG_TOUCHSCREEN_SYNAPTICS_DSX"
    "CONFIG_TOUCHSCREEN_ELAN"
    "CONFIG_TOUCHSCREEN_GT9XX"
)

echo "Options Touch Display activées:"
for option in "${TOUCH_OPTIONS[@]}"; do
    if grep -q "^$option=y" .config; then
        echo "  ✓ $option"
    else
        echo "  ✗ $option"
    fi
done

# Vérification des options RT
echo ""
echo "Options Real-Time activées:"
RT_OPTIONS=(
    "CONFIG_PREEMPT_RT"
    "CONFIG_HIGH_RES_TIMERS"
    "CONFIG_NO_HZ_FULL"
    "CONFIG_CPU_ISOLATION"
)

for option in "${RT_OPTIONS[@]}"; do
    if grep -q "^$option=y" .config; then
        echo "  ✓ $option"
    else
        echo "  ✗ $option"
    fi
done

# Vérification des options Pisound
echo ""
echo "Options Pisound activées:"
PISOUND_OPTIONS=(
    "CONFIG_SND_BCM2708_SOC_PISOUND"
    "CONFIG_SND_BCM2708_SOC_PISOUND_ADC"
    "CONFIG_SND_BCM2708_SOC_PISOUND_DAC"
)

for option in "${PISOUND_OPTIONS[@]}"; do
    if grep -q "^$option=y" .config; then
        echo "  ✓ $option"
    else
        echo "  ✗ $option"
    fi
done

# Vérification des modules compilés
echo ""
echo "Vérification des modules Touch Display compilés:"
cd ../../output/lib/modules/*/kernel/drivers/input/touchscreen/ 2>/dev/null || {
    echo "  Répertoire des modules non trouvé"
    exit 1
}

ls -la *.ko 2>/dev/null || echo "  Aucun module Touch Display trouvé"

echo ""
echo "=== Vérification terminée ==="