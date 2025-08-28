#!/bin/bash

echo "=== Vérification de l'environnement de cross-compilation ==="

# Vérification des variables d'environnement
echo "Variables d'environnement:"
echo "  ARCH: ${ARCH:-non définie}"
echo "  CROSS_COMPILE: ${CROSS_COMPILE:-non définie}"
echo "  KERNEL_VERSION: ${KERNEL_VERSION:-non définie}"
echo "  RT_PATCH_VERSION: ${RT_PATCH_VERSION:-non définie}"

# Vérification des outils de cross-compilation
echo ""
echo "Outils de cross-compilation:"
if command -v aarch64-linux-gnu-gcc &> /dev/null; then
    echo "  ✓ aarch64-linux-gnu-gcc: $(aarch64-linux-gnu-gcc --version | head -n1)"
else
    echo "  ✗ aarch64-linux-gnu-gcc: non trouvé"
fi

if command -v aarch64-linux-gnu-ld &> /dev/null; then
    echo "  ✓ aarch64-linux-gnu-ld: $(aarch64-linux-gnu-ld --version | head -n1)"
else
    echo "  ✗ aarch64-linux-gnu-ld: non trouvé"
fi

if command -v aarch64-linux-gnu-objcopy &> /dev/null; then
    echo "  ✓ aarch64-linux-gnu-objcopy: trouvé"
else
    echo "  ✗ aarch64-linux-gnu-objcopy: non trouvé"
fi

# Vérification des outils de compilation
echo ""
echo "Outils de compilation:"
if command -v make &> /dev/null; then
    echo "  ✓ make: $(make --version | head -n1)"
else
    echo "  ✗ make: non trouvé"
fi

if command -v bc &> /dev/null; then
    echo "  ✓ bc: trouvé"
else
    echo "  ✗ bc: non trouvé"
fi

if command -v bison &> /dev/null; then
    echo "  ✓ bison: trouvé"
else
    echo "  ✗ bison: non trouvé"
fi

if command -v flex &> /dev/null; then
    echo "  ✓ flex: trouvé"
else
    echo "  ✗ flex: non trouvé"
fi

# Vérification des bibliothèques de développement
echo ""
echo "Bibliothèques de développement:"
if pkg-config --exists libssl; then
    echo "  ✓ libssl: $(pkg-config --modversion libssl)"
else
    echo "  ✗ libssl: non trouvé"
fi

if pkg-config --exists ncurses; then
    echo "  ✓ ncurses: $(pkg-config --modversion ncurses)"
else
    echo "  ✗ ncurses: non trouvé"
fi

# Vérification de l'espace disque
echo ""
echo "Espace disque:"
df -h . | tail -n1

# Vérification de la mémoire disponible
echo ""
echo "Mémoire disponible:"
free -h

# Vérification des répertoires de travail
echo ""
echo "Répertoires de travail:"
for dir in kernel output configs scripts; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir: $(du -sh $dir 2>/dev/null | cut -f1)"
    else
        echo "  ✗ $dir: non trouvé"
    fi
done

echo ""
echo "=== Vérification terminée ==="