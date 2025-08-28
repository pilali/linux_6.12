#!/bin/bash

# Script de vérification de l'environnement de compilation
# Vérifie que tous les composants nécessaires sont présents

set -e

echo "=== Vérification de l'environnement de compilation ==="
echo ""

# Vérification des répertoires
echo "Vérification des répertoires..."
REQUIRED_DIRS=("scripts" "configs" "kernel" "output")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ Répertoire $dir trouvé"
    else
        echo "❌ Répertoire $dir manquant"
        exit 1
    fi
done

# Vérification des scripts
echo ""
echo "Vérification des scripts..."
REQUIRED_SCRIPTS=(
    "scripts/init.sh"
    "scripts/extract-patchbox-config.sh"
    "scripts/configure-touch-display.sh"
    "scripts/build-kernel.sh"
    "scripts/merge-configs.sh"
    "scripts/build-complete.sh"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "✓ Script $script trouvé et exécutable"
    else
        echo "❌ Script $script manquant ou non exécutable"
        exit 1
    fi
done

# Vérification des fichiers de configuration
echo ""
echo "Vérification des fichiers de configuration..."
if [ -f "docker-compose.yml" ]; then
    echo "✓ docker-compose.yml trouvé"
else
    echo "❌ docker-compose.yml manquant"
    exit 1
fi

if [ -f "Dockerfile" ]; then
    echo "✓ Dockerfile trouvé"
else
    echo "❌ Dockerfile manquant"
    exit 1
fi

if [ -f "configs/touch-display-2.conf" ]; then
    echo "✓ Configuration Touch Display 2 trouvée"
else
    echo "⚠ Configuration Touch Display 2 manquante"
fi

# Vérification de la configuration PatchboxOS
echo ""
echo "Vérification de la configuration PatchboxOS..."
if [ -f "configs/patchbox-config" ]; then
    echo "✓ Configuration PatchboxOS trouvée"
    
    # Vérification du contenu
    if grep -q "CONFIG_SND" "configs/patchbox-config"; then
        echo "  ✓ Support audio détecté"
    else
        echo "  ⚠ Support audio non détecté"
    fi
    
    if grep -q "CONFIG_PREEMPT_RT" "configs/patchbox-config"; then
        echo "  ✓ Support real-time détecté"
    else
        echo "  ⚠ Support real-time non détecté"
    fi
    
    if grep -q "CONFIG_TOUCHSCREEN" "configs/patchbox-config"; then
        echo "  ✓ Support écran tactile détecté"
    else
        echo "  ⚠ Support écran tactile non détecté"
    fi
else
    echo "⚠ Configuration PatchboxOS non trouvée"
    echo "  Exécutez d'abord le script extract-patchbox-config.sh sur votre Raspberry Pi"
fi

# Vérification de l'environnement Docker
echo ""
echo "Vérification de l'environnement Docker..."
if command -v docker >/dev/null 2>&1; then
    echo "✓ Docker installé"
    docker --version
    
    if docker info >/dev/null 2>&1; then
        echo "✓ Docker en cours d'exécution"
    else
        echo "❌ Docker n'est pas en cours d'exécution"
        echo "  Démarrez Docker Desktop et réessayez"
        exit 1
    fi
else
    echo "❌ Docker non installé"
    echo "  Installez Docker Desktop depuis https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Vérification de docker-compose
if command -v docker-compose >/dev/null 2>&1; then
    echo "✓ docker-compose installé"
    docker-compose --version
elif docker compose version >/dev/null 2>&1; then
    echo "✓ docker compose installé (version moderne)"
    docker compose version
else
    echo "❌ docker-compose non installé"
    echo "  Installez docker-compose ou utilisez 'docker compose' (version moderne)"
    exit 1
fi

# Vérification de l'espace disque
echo ""
echo "Vérification de l'espace disque..."
AVAILABLE_SPACE=$(df . | awk 'NR==2 {print $4}')
AVAILABLE_SPACE_GB=$((AVAILABLE_SPACE / 1024 / 1024))

if [ $AVAILABLE_SPACE_GB -ge 20 ]; then
    echo "✓ Espace disque suffisant: ${AVAILABLE_SPACE_GB} GB disponible"
else
    echo "⚠ Espace disque limité: ${AVAILABLE_SPACE_GB} GB disponible (20 GB recommandé)"
fi

# Vérification de la mémoire
echo ""
echo "Vérification de la mémoire..."
if command -v free >/dev/null 2>&1; then
    TOTAL_MEM=$(free -m | awk 'NR==2{print $2}')
    TOTAL_MEM_GB=$((TOTAL_MEM / 1024))
    
    if [ $TOTAL_MEM_GB -ge 8 ]; then
        echo "✓ Mémoire suffisante: ${TOTAL_MEM_GB} GB disponible"
    else
        echo "⚠ Mémoire limitée: ${TOTAL_MEM_GB} GB disponible (8 GB recommandé)"
    fi
else
    echo "⚠ Impossible de vérifier la mémoire"
fi

# Vérification des outils de compilation
echo ""
echo "Vérification des outils de compilation..."
if command -v gcc >/dev/null 2>&1; then
    echo "✓ Compilateur GCC disponible"
else
    echo "⚠ Compilateur GCC non disponible (sera installé dans Docker)"
fi

if command -v make >/dev/null 2>&1; then
    echo "✓ Make disponible"
else
    echo "⚠ Make non disponible (sera installé dans Docker)"
fi

# Résumé
echo ""
echo "========================================"
echo "Résumé de la vérification:"
echo ""

if [ -f "configs/patchbox-config" ]; then
    echo "✅ Environnement prêt pour la compilation!"
    echo ""
    echo "Prochaines étapes:"
    echo "1. docker compose build"
    echo "2. docker compose up -d"
    echo "3. docker compose exec kernel-builder bash"
    echo "4. ./scripts/build-complete.sh"
else
    echo "⚠ Configuration PatchboxOS manquante"
    echo ""
    echo "Étapes à effectuer:"
    echo "1. Exécutez extract-patchbox-config.sh sur votre Raspberry Pi"
    echo "2. Copiez le fichier patchbox-config vers ./configs/"
    echo "3. Relancez ce script de vérification"
fi

echo ""
echo "========================================"