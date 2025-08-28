# Guide de déploiement du noyau Linux 6.12 RT pour Raspberry Pi 4

Ce guide vous accompagne dans le processus de cross-compilation et de déploiement d'un noyau Linux 6.12 avec patches Real-Time optimisé pour PatchboxOS avec support du Touch Display 2 et Pisound.

## Prérequis

- PC Windows avec Docker Desktop installé
- Docker Compose
- Make (via Git Bash ou WSL)
- Carte SD avec PatchboxOS existant (pour récupérer la configuration)
- Raspberry Pi 4 avec Pisound et Touch Display 2

## Étape 1: Construction de l'environnement

```bash
# Cloner ce repository
git clone <url-du-repo>
cd linux-6.12

# Construire l'environnement Docker
make build
```

## Étape 2: Récupération de la configuration PatchboxOS (Optionnel)

Si vous avez accès à votre système PatchboxOS existant:

```bash
# Sur le Raspberry Pi PatchboxOS
sudo modprobe configs
zcat /proc/config.gz > /tmp/patchbox-config

# Ou si /proc/config.gz n'existe pas:
sudo find /boot -name 'config-*' -exec cp {} /tmp/patchbox-config \;

# Transférer le fichier vers votre PC Windows
scp patch@192.168.0.34:/tmp/patchbox-config ./
```

Puis adapter la configuration:

```bash
make shell
# Dans le container:
./extract-patchbox-config.sh patchbox-config
```

## Étape 3: Compilation complète

### Option A: Compilation automatique complète
```bash
make full-build
```

### Option B: Compilation étape par étape
```bash
make shell

# Dans le container Docker:
# 1. Téléchargement et préparation
./build-kernel.sh

# 2. Configuration spécifique
./configure-patchbox-features.sh

# 3. Compilation
cd /kernel-build/linux-6.12
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules -j$(nproc)

# 4. Installation des modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/kernel-build/output modules_install

# 5. Copie des fichiers finaux
cp arch/arm64/boot/Image /kernel-build/output/kernel8.img
cp arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /kernel-build/output/
```

## Étape 4: Récupération des fichiers compilés

```bash
make copy-output
```

Les fichiers seront disponibles dans le dossier `output/`:
- `kernel8.img`: Image du noyau
- `bcm2711-rpi-4-b.dtb`: Device Tree Blob
- `lib/modules/`: Modules du noyau

## Étape 5: Déploiement sur Raspberry Pi

### Sauvegarde du système existant
```bash
sudo cp /boot/kernel8.img /boot/kernel8.img.patchbox-backup
sudo cp /boot/bcm2711-rpi-4-b.dtb /boot/bcm2711-rpi-4-b.dtb.backup
```

### Installation du nouveau noyau
```bash
# Copier les fichiers depuis votre PC vers le Pi
scp output/kernel8.img patch@192.168.0.34:/tmp/
scp output/bcm2711-rpi-4-b.dtb patch@192.168.0.34:/tmp/
scp -r output/lib/modules/* patch@192.168.0.34:/tmp/

# Sur le Raspberry Pi:
sudo cp /tmp/kernel8.img /boot/
sudo cp /tmp/bcm2711-rpi-4-b.dtb /boot/
sudo cp -r /tmp/modules/* /lib/modules/
sudo depmod -a
```

## Étape 6: Configuration /boot/config.txt

Éditer `/boot/config.txt` et s'assurer que les lignes suivantes sont présentes:

```ini
# Support écran tactile
dtoverlay=vc4-kms-v3d
dtoverlay=rpi-ft5406

# Support Pisound
dtoverlay=pisound

# Optimisations
disable_splash=1
dtparam=audio=on

# Real-time optimizations
isolcpus=3
rcu_nocbs=3
irqaffinity=0,1,2
```

## Étape 7: Paramètres de démarrage optimisés

Éditer `/boot/cmdline.txt` et ajouter:

```
dwc_otg.fiq_fsm_enable=0 dwc_otg.fiq_enable=0 dwc_otg.nak_holdoff=0 isolcpus=3 rcu_nocbs=3 irqaffinity=0-2 threadirqs
```

## Étape 8: Redémarrage et vérification

```bash
sudo reboot
```

Après redémarrage, vérifier:

```bash
# Version du noyau
uname -a
# Doit afficher: Linux ... 6.12.x-rt10+ ... aarch64

# Support Real-Time
cat /sys/kernel/realtime
# Doit afficher: 1

# Support audio Pisound
aplay -l
# Doit lister le périphérique Pisound

# Support écran tactile
dmesg | grep -i touch
dmesg | grep -i ft6236
# Doit afficher la détection du contrôleur tactile

# Test tactile
xinput list
# Doit lister le périphérique tactile
```

## Dépannage

### Problème: Le système ne démarre pas
1. Réinsérer la carte SD dans un PC
2. Restaurer la sauvegarde: `cp kernel8.img.patchbox-backup kernel8.img`
3. Redémarrer et vérifier la configuration

### Problème: Écran tactile non reconnu
1. Vérifier dans `/boot/config.txt`: `dtoverlay=rpi-ft5406`
2. Vérifier les logs: `dmesg | grep -i ft`
3. Tester avec: `evtest`

### Problème: Pisound non reconnu
1. Vérifier dans `/boot/config.txt`: `dtoverlay=pisound`
2. Vérifier les logs: `dmesg | grep -i pisound`
3. Tester avec: `aplay -l` et `arecord -l`

### Problème: Latence audio élevée
1. Vérifier RT: `cat /sys/kernel/realtime`
2. Ajuster les paramètres JACK/PipeWire
3. Vérifier l'isolation des CPUs: `cat /proc/cmdline`

## Performance et optimisation

### Test de latence Real-Time
```bash
# Installation de rt-tests si nécessaire
sudo apt install rt-tests

# Test de latence
sudo cyclictest -t1 -p 80 -n -i 500 -l 100000
```

### Optimisation audio
```bash
# Configuration JACK optimisée
jackd -R -P75 -dalsa -dhw:pisound -r48000 -p128 -n2

# Test de latence audio
jack_iodelay
```

## Fichiers importants

- `Dockerfile`: Environnement de cross-compilation
- `build-kernel.sh`: Script de compilation principal
- `configure-patchbox-features.sh`: Configuration spécialisée
- `extract-patchbox-config.sh`: Extraction config PatchboxOS
- `Makefile`: Commandes simplifiées
- `docker-compose.yml`: Orchestration Docker

## Commandes utiles

```bash
make help              # Afficher l'aide
make build            # Construire l'environnement
make shell            # Shell interactif
make full-build       # Compilation complète
make copy-output      # Copier les fichiers
make clean            # Nettoyer
make deploy-help      # Instructions déploiement
```