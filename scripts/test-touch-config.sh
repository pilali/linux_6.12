#!/bin/bash

# Script de test pour vérifier la configuration Touch Display 2
# Teste la compatibilité des options de configuration

set -e

echo "=== Test de la configuration Touch Display 2 ==="
echo ""

# Vérification de la configuration Touch Display 2
if [ -f "./configs/touch-display-2.conf" ]; then
    echo "✓ Configuration Touch Display 2 trouvée"
    
    # Test des options essentielles
    ESSENTIAL_OPTIONS=(
        "CONFIG_TOUCHSCREEN=y"
        "CONFIG_DRM_PANEL_SIMPLE=y"
        "CONFIG_I2C=y"
        "CONFIG_SPI=y"
        "CONFIG_INPUT=y"
    )
    
    echo ""
    echo "Test des options essentielles:"
    for option in "${ESSENTIAL_OPTIONS[@]}"; do
        if grep -q "^$option" "./configs/touch-display-2.conf"; then
            echo "  ✓ $option"
        else
            echo "  ❌ $option manquante"
        fi
    done
    
    # Test des options avancées
    ADVANCED_OPTIONS=(
        "CONFIG_TOUCHSCREEN_ADS7846=y"
        "CONFIG_TOUCHSCREEN_GOODIX=y"
        "CONFIG_DRM_MIPI_DSI=y"
        "CONFIG_DRM_VC4=y"
    )
    
    echo ""
    echo "Test des options avancées:"
    for option in "${ADVANCED_OPTIONS[@]}"; do
        if grep -q "^$option" "./configs/touch-display-2.conf"; then
            echo "  ✓ $option"
        else
            echo "  ⚠ $option manquante (optionnel)"
        fi
    done
    
else
    echo "❌ Configuration Touch Display 2 non trouvée"
    exit 1
fi

# Vérification de la configuration PatchboxOS
echo ""
echo "Test de la configuration PatchboxOS:"
if [ -f "./configs/patchbox-config" ]; then
    echo "✓ Configuration PatchboxOS trouvée"
    
    # Test des options audio
    if grep -q "CONFIG_SND" "./configs/patchbox-config"; then
        echo "  ✓ Support audio détecté"
    else
        echo "  ⚠ Support audio non détecté"
    fi
    
    # Test des options real-time
    if grep -q "CONFIG_PREEMPT_RT" "./configs/patchbox-config"; then
        echo "  ✓ Support real-time détecté"
    else
        echo "  ⚠ Support real-time non détecté"
    fi
    
else
    echo "⚠ Configuration PatchboxOS non trouvée"
fi

# Test de la compatibilité des configurations
echo ""
echo "Test de compatibilité des configurations:"
echo "Vérification des conflits potentiels..."

# Vérification des options en conflit
CONFLICT_OPTIONS=(
    "CONFIG_TOUCHSCREEN"
    "CONFIG_DRM"
    "CONFIG_I2C"
    "CONFIG_SPI"
)

for option in "${CONFLICT_OPTIONS[@]}"; do
    if [ -f "./configs/patchbox-config" ]; then
        patchbox_value=$(grep "^$option=" "./configs/patchbox-config" | cut -d'=' -f2 || echo "not_set")
        touch_value=$(grep "^$option=" "./configs/touch-display-2.conf" | cut -d'=' -f2 || echo "not_set")
        
        if [ "$patchbox_value" != "not_set" ] && [ "$touch_value" != "not_set" ]; then
            if [ "$patchbox_value" = "$touch_value" ]; then
                echo "  ✓ $option: Compatible ($patchbox_value)"
            else
                echo "  ⚠ $option: Conflit potentiel (PatchboxOS: $patchbox_value, Touch: $touch_value)"
            fi
        else
            echo "  ℹ $option: Pas de conflit détecté"
        fi
    fi
done

# Test des dépendances
echo ""
echo "Test des dépendances:"
DEPENDENCIES=(
    "CONFIG_INPUT_EVDEV"
    "CONFIG_USB_SUPPORT"
    "CONFIG_GPIO_SYSFS"
)

for dep in "${DEPENDENCIES[@]}"; do
    if grep -q "^$dep=y" "./configs/touch-display-2.conf"; then
        echo "  ✓ $dep activé"
    else
        echo "  ⚠ $dep non activé (peut causer des problèmes)"
    fi
done

# Résumé du test
echo ""
echo "========================================"
echo "Résumé du test de configuration:"
echo ""

# Comptage des options
total_options=$(grep -c "^CONFIG_" "./configs/touch-display-2.conf" || echo "0")
enabled_options=$(grep -c "^CONFIG_.*=y" "./configs/touch-display-2.conf" || echo "0")

echo "Options Touch Display 2: $total_options total, $enabled_options activées"

if [ -f "./configs/patchbox-config" ]; then
    patchbox_options=$(grep -c "^CONFIG_" "./configs/patchbox-config" || echo "0")
    echo "Options PatchboxOS: $patchbox_options total"
fi

echo ""
if [ $enabled_options -ge 50 ]; then
    echo "✅ Configuration Touch Display 2 complète et prête pour la compilation!"
else
    echo "⚠ Configuration Touch Display 2 incomplète, certains périphériques peuvent ne pas être reconnus"
fi

echo ""
echo "Prochaines étapes:"
echo "1. Vérifiez que toutes les options essentielles sont ✓"
echo "2. Lancez la compilation: ./scripts/build-complete.sh"
echo "3. Installez le noyau compilé sur votre Raspberry Pi"