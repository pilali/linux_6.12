#!/bin/bash

# Script pour configurer le support du Touch Display 2
# À exécuter après avoir extrait la configuration PatchboxOS

set -e

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ]; then
    echo "Usage: $0 <fichier_config>"
    echo "Exemple: $0 ./configs/patchbox-config"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erreur: Fichier de configuration $CONFIG_FILE non trouvé"
    exit 1
fi

echo "=== Configuration du support Touch Display 2 ==="
echo "Fichier de configuration: $CONFIG_FILE"

# Création d'une sauvegarde
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
echo "Sauvegarde créée: ${CONFIG_FILE}.backup"

# Configuration des options pour Touch Display 2
echo "Configuration des options Touch Display 2..."

# Support des écrans tactiles
sed -i 's/# CONFIG_TOUCHSCREEN_ADS7846 is not set/CONFIG_TOUCHSCREEN_ADS7846=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_TOUCHSCREEN_GOODIX is not set/CONFIG_TOUCHSCREEN_GOODIX=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_TOUCHSCREEN_ILI210X is not set/CONFIG_TOUCHSCREEN_ILI210X=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_TOUCHSCREEN_MTK is not set/CONFIG_TOUCHSCREEN_MTK=y/' "$CONFIG_FILE"

# Support des écrans LCD
sed -i 's/# CONFIG_DRM_PANEL_SIMPLE is not set/CONFIG_DRM_PANEL_SIMPLE=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_DRM_PANEL_ILITEK_ILI9881C is not set/CONFIG_DRM_PANEL_ILITEK_ILI9881C=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_DRM_PANEL_ORISETECH_OTM8009A is not set/CONFIG_DRM_PANEL_ORISETECH_OTM8009A=y/' "$CONFIG_FILE"

# Support des contrôleurs d'affichage
sed -i 's/# CONFIG_DRM_MIPI_DSI is not set/CONFIG_DRM_MIPI_DSI=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_DRM_VC4 is not set/CONFIG_DRM_VC4=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_DRM_VC4_HDMI_CEC is not set/CONFIG_DRM_VC4_HDMI_CEC=y/' "$CONFIG_FILE"

# Support des interfaces I2C pour l'écran
sed -i 's/# CONFIG_I2C is not set/CONFIG_I2C=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_I2C_CHARDEV is not set/CONFIG_I2C_CHARDEV=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_I2C_HELPER_AUTO is not set/CONFIG_I2C_HELPER_AUTO=y/' "$CONFIG_FILE"

# Support des contrôleurs I2C Broadcom
sed -i 's/# CONFIG_I2C_BCM2708 is not set/CONFIG_I2C_BCM2708=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_I2C_BCM2835 is not set/CONFIG_I2C_BCM2835=y/' "$CONFIG_FILE"

# Support des périphériques d'entrée
sed -i 's/# CONFIG_INPUT is not set/CONFIG_INPUT=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_INPUT_EVDEV is not set/CONFIG_INPUT_EVDEV=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_INPUT_TOUCHSCREEN is not set/CONFIG_INPUT_TOUCHSCREEN=y/' "$CONFIG_FILE"

# Support des écrans tactiles capacitifs
sed -i 's/# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set/CONFIG_TOUCHSCREEN_CYTTSP_CORE=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_TOUCHSCREEN_CYTTSP_I2C is not set/CONFIG_TOUCHSCREEN_CYTTSP_I2C=y/' "$CONFIG_FILE"

# Support des écrans tactiles résistifs
sed -i 's/# CONFIG_TOUCHSCREEN_ADS7846 is not set/CONFIG_TOUCHSCREEN_ADS7846=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_TOUCHSCREEN_ADS7846_PRESSURE is not set/CONFIG_TOUCHSCREEN_ADS7846_PRESSURE=y/' "$CONFIG_FILE"

# Support des écrans tactiles USB
sed -i 's/# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set/CONFIG_TOUCHSCREEN_USB_COMPOSITE=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_TOUCHSCREEN_USB_EGALAX is not set/CONFIG_TOUCHSCREEN_USB_EGALAX=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_TOUCHSCREEN_USB_3M is not set/CONFIG_TOUCHSCREEN_USB_3M=y/' "$CONFIG_FILE"

# Support des écrans tactiles HID
sed -i 's/# CONFIG_HID is not set/CONFIG_HID=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_HID_GENERIC is not set/CONFIG_HID_GENERIC=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_HID_MULTITOUCH is not set/CONFIG_HID_MULTITOUCH=y/' "$CONFIG_FILE"

# Support des écrans tactiles spécifiques au Raspberry Pi
sed -i 's/# CONFIG_TOUCHSCREEN_RASPBERRYPI_FW is not set/CONFIG_TOUCHSCREEN_RASPBERRYPI_FW=y/' "$CONFIG_FILE"

# Support des écrans tactiles via GPIO
sed -i 's/# CONFIG_TOUCHSCREEN_ADS7846 is not set/CONFIG_TOUCHSCREEN_ADS7846=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_TOUCHSCREEN_ADS7846_PRESSURE is not set/CONFIG_TOUCHSCREEN_ADS7846_PRESSURE=y/' "$CONFIG_FILE"

# Support des écrans tactiles via SPI
sed -i 's/# CONFIG_SPI is not set/CONFIG_SPI=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_SPI_MASTER is not set/CONFIG_SPI_MASTER=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_SPI_BCM2835 is not set/CONFIG_SPI_BCM2835=y/' "$CONFIG_FILE"

# Support des écrans tactiles via USB
sed -i 's/# CONFIG_USB is not set/CONFIG_USB=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_USB_SUPPORT is not set/CONFIG_USB_SUPPORT=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_USB_DWC2 is not set/CONFIG_USB_DWC2=y/' "$CONFIG_FILE"

# Support des écrans tactiles via Bluetooth
sed -i 's/# CONFIG_BT is not set/CONFIG_BT=y/' "$CONFIG_FILE"
sed -i 's/# CONFIG_BT_HIDP is not set/CONFIG_BT_HIDP=y/' "$CONFIG_FILE"

echo "Configuration Touch Display 2 terminée!"
echo "Fichier modifié: $CONFIG_FILE"
echo "Sauvegarde: ${CONFIG_FILE}.backup"

# Vérification des modifications
echo ""
echo "Vérification des options configurées:"
grep -E "CONFIG_TOUCHSCREEN|CONFIG_DRM_PANEL|CONFIG_I2C|CONFIG_INPUT" "$CONFIG_FILE" | head -20