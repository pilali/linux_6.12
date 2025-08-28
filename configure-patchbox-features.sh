#!/bin/bash
# Script pour configurer le noyau avec les spécificités PatchboxOS
# Support optimal pour Pisound et Touch Display 2

set -e

KERNEL_DIR="/kernel-build/linux-6.12"

if [ ! -d "$KERNEL_DIR" ]; then
    echo "Erreur: Répertoire du noyau non trouvé: $KERNEL_DIR"
    exit 1
fi

cd $KERNEL_DIR

echo "=== Configuration spécifique PatchboxOS ==="

# Configuration Real-Time optimisée
echo "Configuration Real-Time..."
scripts/config --enable CONFIG_PREEMPT_RT
scripts/config --enable CONFIG_PREEMPT_RT_FULL
scripts/config --enable CONFIG_PREEMPT_RCU
scripts/config --set-val CONFIG_RCU_FANOUT 32
scripts/config --enable CONFIG_NO_HZ_FULL
scripts/config --enable CONFIG_HIGH_RES_TIMERS
scripts/config --enable CONFIG_HRTIMERS
scripts/config --set-val CONFIG_HZ 1000
scripts/config --enable CONFIG_IRQ_FORCED_THREADING

# Audio professionnel et support Pisound
echo "Configuration audio professionnelle pour Pisound..."

# Core audio
scripts/config --enable CONFIG_SOUND
scripts/config --enable CONFIG_SND
scripts/config --enable CONFIG_SND_TIMER
scripts/config --enable CONFIG_SND_PCM
scripts/config --enable CONFIG_SND_RAWMIDI
scripts/config --enable CONFIG_SND_SEQUENCER
scripts/config --enable CONFIG_SND_SEQ_DUMMY

# ALSA
scripts/config --enable CONFIG_SND_OSSEMUL
scripts/config --enable CONFIG_SND_MIXER_OSS
scripts/config --enable CONFIG_SND_PCM_OSS
scripts/config --enable CONFIG_SND_SEQUENCER_OSS

# Support USB Audio avancé
scripts/config --enable CONFIG_SND_USB_AUDIO
scripts/config --enable CONFIG_SND_USB_UA101
scripts/config --enable CONFIG_SND_USB_US122L
scripts/config --enable CONFIG_SND_USB_6FIRE
scripts/config --enable CONFIG_SND_USB_HIFACE
scripts/config --enable CONFIG_SND_USB_CAIAQ
scripts/config --enable CONFIG_SND_USB_CAIAQ_INPUT

# Support MIDI
scripts/config --enable CONFIG_SND_RAWMIDI
scripts/config --enable CONFIG_SND_MPU401_UART
scripts/config --enable CONFIG_SND_USB_CAIAQ

# Support Raspberry Pi audio
scripts/config --enable CONFIG_SND_BCM2835
scripts/config --enable CONFIG_SND_ARM
scripts/config --enable CONFIG_SND_ARMAACI

# Support écran tactile Raspberry Pi Touch Display 2
echo "Configuration Touch Display 2..."

# DRM et framebuffer
scripts/config --enable CONFIG_DRM
scripts/config --enable CONFIG_DRM_KMS_HELPER
scripts/config --enable CONFIG_DRM_VC4
scripts/config --enable CONFIG_DRM_VC4_HDMI_CEC
scripts/config --enable CONFIG_DRM_PANEL
scripts/config --enable CONFIG_DRM_PANEL_SIMPLE

# Support DSI (Display Serial Interface)
scripts/config --enable CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN

# Framebuffer
scripts/config --enable CONFIG_FB
scripts/config --enable CONFIG_FB_SIMPLE
scripts/config --enable CONFIG_FB_SYS_FILLRECT
scripts/config --enable CONFIG_FB_SYS_COPYAREA
scripts/config --enable CONFIG_FB_SYS_IMAGEBLIT
scripts/config --enable CONFIG_FB_SYS_FOPS

# Backlight
scripts/config --enable CONFIG_BACKLIGHT_CLASS_DEVICE
scripts/config --enable CONFIG_BACKLIGHT_GENERIC
scripts/config --enable CONFIG_BACKLIGHT_RPI

# Support tactile
echo "Configuration du tactile..."
scripts/config --enable CONFIG_INPUT_TOUCHSCREEN
scripts/config --enable CONFIG_TOUCHSCREEN_FT6236
scripts/config --enable CONFIG_TOUCHSCREEN_GOODIX
scripts/config --enable CONFIG_TOUCHSCREEN_EDT_FT5X06
scripts/config --enable CONFIG_HID_MULTITOUCH
scripts/config --enable CONFIG_INPUT_POLLDEV

# I2C et SPI pour les périphériques
echo "Configuration I2C/SPI..."
scripts/config --enable CONFIG_I2C
scripts/config --enable CONFIG_I2C_CHARDEV
scripts/config --enable CONFIG_I2C_BCM2835
scripts/config --enable CONFIG_I2C_SLAVE
scripts/config --enable CONFIG_SPI
scripts/config --enable CONFIG_SPI_BCM2835
scripts/config --enable CONFIG_SPI_BCM2835AUX
scripts/config --enable CONFIG_SPI_SPIDEV

# GPIO
echo "Configuration GPIO..."
scripts/config --enable CONFIG_GPIOLIB
scripts/config --enable CONFIG_GPIOLIB_FASTPATH_LIMIT
scripts/config --enable CONFIG_GPIO_SYSFS
scripts/config --enable CONFIG_GPIO_BCM_VIRT

# Device Tree Overlay support
scripts/config --enable CONFIG_OF
scripts/config --enable CONFIG_OF_OVERLAY
scripts/config --enable CONFIG_OF_CONFIGFS

# Support PWM pour le rétroéclairage
scripts/config --enable CONFIG_PWM
scripts/config --enable CONFIG_PWM_BCM2835

# Optimisations de performance
echo "Optimisations de performance..."
scripts/config --set-val CONFIG_HZ 1000
scripts/config --enable CONFIG_HIGH_RES_TIMERS
scripts/config --disable CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND
scripts/config --enable CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE

# Support des codecs audio
scripts/config --enable CONFIG_SND_SOC
scripts/config --enable CONFIG_SND_BCM2835_SOC_I2S

# Options de débogage désactivées pour les performances
scripts/config --disable CONFIG_DEBUG_KERNEL
scripts/config --disable CONFIG_DEBUG_INFO
scripts/config --disable CONFIG_PROVE_LOCKING
scripts/config --disable CONFIG_DEBUG_ATOMIC_SLEEP

echo "Configuration spécifique PatchboxOS terminée."
echo "Le noyau est maintenant configuré pour:"
echo "- Real-time avec patches RT"
echo "- Support optimal du Pisound"
echo "- Support du Touch Display 2"
echo "- Optimisations audio faible latence"