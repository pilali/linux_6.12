#!/bin/bash

# Script pour fusionner la configuration PatchboxOS avec la nouvelle configuration
# du noyau 6.12+ en préservant les options importantes

set -e

PATCHBOX_CONFIG="$1"
NEW_CONFIG="$2"

if [ -z "$PATCHBOX_CONFIG" ] || [ -z "$NEW_CONFIG" ]; then
    echo "Usage: $0 <config_patchbox> <config_nouveau>"
    echo "Exemple: $0 ./configs/patchbox-config ./configs/.config"
    exit 1
fi

if [ ! -f "$PATCHBOX_CONFIG" ]; then
    echo "Erreur: Configuration PatchboxOS $PATCHBOX_CONFIG non trouvée"
    exit 1
fi

if [ ! -f "$NEW_CONFIG" ]; then
    echo "Erreur: Nouvelle configuration $NEW_CONFIG non trouvée"
    exit 1
fi

echo "=== Fusion des configurations ==="
echo "Configuration PatchboxOS: $PATCHBOX_CONFIG"
echo "Nouvelle configuration: $NEW_CONFIG"

# Création d'une sauvegarde
cp "$NEW_CONFIG" "${NEW_CONFIG}.backup"
echo "Sauvegarde créée: ${NEW_CONFIG}.backup"

# Répertoire temporaire
TEMP_DIR=$(mktemp -d)
echo "Répertoire temporaire: $TEMP_DIR"

# Extraction des options importantes de PatchboxOS
echo "Extraction des options importantes de PatchboxOS..."

# Options audio et real-time
grep -E "CONFIG_SND|CONFIG_SOUND|CONFIG_RT_GROUP_SCHED|CONFIG_PREEMPT_RT|CONFIG_HIGH_RES_TIMERS" "$PATCHBOX_CONFIG" > "$TEMP_DIR/audio-rt-options.txt" 2>/dev/null || true

# Options de périphériques
grep -E "CONFIG_USB|CONFIG_I2C|CONFIG_SPI|CONFIG_GPIO|CONFIG_SERIAL" "$PATCHBOX_CONFIG" > "$TEMP_DIR/device-options.txt" 2>/dev/null || true

# Options de système de fichiers
grep -E "CONFIG_EXT4|CONFIG_FAT|CONFIG_NTFS|CONFIG_CIFS|CONFIG_NFS" "$PATCHBOX_CONFIG" > "$TEMP_DIR/fs-options.txt" 2>/dev/null || true

# Options réseau
grep -E "CONFIG_NET|CONFIG_INET|CONFIG_WIRELESS|CONFIG_BT" "$PATCHBOX_CONFIG" > "$TEMP_DIR/network-options.txt" 2>/dev/null || true

# Options de sécurité
grep -E "CONFIG_SECURITY|CONFIG_CRYPTO|CONFIG_KEYS" "$PATCHBOX_CONFIG" > "$TEMP_DIR/security-options.txt" 2>/dev/null || true

echo "Options extraites dans $TEMP_DIR"

# Application des options PatchboxOS à la nouvelle configuration
echo "Application des options PatchboxOS..."

# Fonction pour appliquer une option si elle existe dans la nouvelle config
apply_option() {
    local option="$1"
    local value="$2"
    
    if grep -q "^$option=" "$NEW_CONFIG"; then
        # L'option existe, on la met à jour
        sed -i "s/^$option=.*/$option=$value/" "$NEW_CONFIG"
    elif grep -q "^# $option is not set" "$NEW_CONFIG"; then
        # L'option est désactivée, on l'active
        sed -i "s/^# $option is not set/$option=$value/" "$NEW_CONFIG"
    else
        # L'option n'existe pas, on l'ajoute
        echo "$option=$value" >> "$NEW_CONFIG"
    fi
}

# Application des options audio et real-time
if [ -s "$TEMP_DIR/audio-rt-options.txt" ]; then
    echo "Application des options audio et real-time..."
    while IFS= read -r line; do
        if [[ $line =~ ^(CONFIG_[A-Z0-9_]+)=(.*)$ ]]; then
            apply_option "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done < "$TEMP_DIR/audio-rt-options.txt"
fi

# Application des options de périphériques
if [ -s "$TEMP_DIR/device-options.txt" ]; then
    echo "Application des options de périphériques..."
    while IFS= read -r line; do
        if [[ $line =~ ^(CONFIG_[A-Z0-9_]+)=(.*)$ ]]; then
            apply_option "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done < "$TEMP_DIR/device-options.txt"
fi

# Application des options de système de fichiers
if [ -s "$TEMP_DIR/fs-options.txt" ]; then
    echo "Application des options de système de fichiers..."
    while IFS= read -r line; do
        if [[ $line =~ ^(CONFIG_[A-Z0-9_]+)=(.*)$ ]]; then
            apply_option "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done < "$TEMP_DIR/fs-options.txt"
fi

# Application des options réseau
if [ -s "$TEMP_DIR/network-options.txt" ]; then
    echo "Application des options réseau..."
    while IFS= read -r line; do
        if [[ $line =~ ^(CONFIG_[A-Z0-9_]+)=(.*)$ ]]; then
            apply_option "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done < "$TEMP_DIR/network-options.txt"
fi

# Application des options de sécurité
if [ -s "$TEMP_DIR/security-options.txt" ]; then
    echo "Application des options de sécurité..."
    while IFS= read -r line; do
        if [[ $line =~ ^(CONFIG_[A-Z0-9_]+)=(.*)$ ]]; then
            apply_option "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    done < "$TEMP_DIR/security-options.txt"
fi

# Nettoyage
rm -rf "$TEMP_DIR"

echo "Fusion terminée!"
echo "Configuration fusionnée: $NEW_CONFIG"
echo "Sauvegarde: ${NEW_CONFIG}.backup"

# Vérification des options importantes
echo ""
echo "Vérification des options importantes:"
grep -E "CONFIG_SND|CONFIG_RT_GROUP_SCHED|CONFIG_PREEMPT_RT|CONFIG_TOUCHSCREEN|CONFIG_DRM" "$NEW_CONFIG" | head -20