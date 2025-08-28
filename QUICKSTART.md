# 🚀 Guide de démarrage rapide

## ⚡ Démarrage en 5 minutes

### 1. Prérequis
- Docker Desktop installé et démarré sur Windows
- Au moins 20 GB d'espace disque libre
- 8 GB de RAM minimum

### 2. Extraction de la configuration PatchboxOS

**Sur votre Raspberry Pi PatchboxOS :**
```bash
# Copiez le script d'extraction
scp scripts/extract-patchbox-config.sh pi@<IP_RASPBERRY>:/tmp/

# Connectez-vous au Raspberry Pi
ssh pi@<IP_RASPBERRY>

# Exécutez le script d'extraction
chmod +x /tmp/extract-patchbox-config.sh
/tmp/extract-patchbox-config.sh
```

**Depuis votre PC Windows :**
```bash
# Copiez la configuration extraite
scp pi@<IP_RASPBERRY>:/tmp/patchbox-config ./configs/
```

### 3. Lancement automatique

**Option A : Script batch (recommandé pour débutants)**
```bash
# Double-cliquez sur start-build.bat
# Ou exécutez depuis PowerShell :
.\start-build.bat
```

**Option B : Script PowerShell (plus de contrôle)**
```powershell
# Vérification complète
.\start-build.ps1

# Ou lancement automatique
.\start-build.ps1 -AutoStart

# Ou sans vérification de config
.\start-build.ps1 -SkipConfigCheck
```

**Option C : Commandes manuelles**
```bash
# Construction de l'image
docker compose build

# Lancement du conteneur
docker compose up -d

# Accès au conteneur
docker compose exec kernel-builder bash

# Compilation complète
./scripts/build-complete.sh
```

## 🔧 Vérification de l'environnement

Avant de commencer, vérifiez que tout est en place :
```bash
./scripts/verify-setup.sh
```

## 📁 Structure du projet

```
rpi-kernel-builder/
├── docker-compose.yml          # Configuration Docker
├── Dockerfile                  # Image Docker
├── start-build.bat            # Script Windows batch
├── start-build.ps1            # Script PowerShell
├── scripts/                    # Scripts de compilation
│   ├── verify-setup.sh        # Vérification de l'environnement
│   ├── extract-patchbox-config.sh  # Extraction config depuis Pi
│   ├── configure-touch-display.sh  # Configuration Touch Display 2
│   ├── build-kernel.sh        # Compilation du noyau
│   ├── merge-configs.sh       # Fusion des configurations
│   └── build-complete.sh      # Script principal
├── configs/                    # Configurations
│   ├── patchbox-config        # Config PatchboxOS (à extraire)
│   ├── patchbox-config-example # Exemple de configuration
│   └── touch-display-2.conf   # Config Touch Display 2
├── kernel/                     # Sources du noyau (créé automatiquement)
└── output/                     # Fichiers compilés (créé automatiquement)
```

## 🎯 Ce qui sera généré

Après compilation, vous obtiendrez dans `./output/` :
- `kernel-6.12.8-rt-final.img` : Noyau compilé avec support RT
- `bcm2711-rpi-4-b.dtb` : Device tree pour Raspberry Pi 4
- `config-6.12.8-rt-final` : Configuration finale du noyau
- `lib/modules/` : Modules du noyau

## 📱 Installation sur Raspberry Pi

```bash
# Sauvegarde de l'ancien noyau
sudo cp /boot/kernel8.img /boot/kernel8.img.backup

# Installation du nouveau noyau
sudo cp kernel-6.12.8-rt-final.img /boot/kernel8.img
sudo cp bcm2711-rpi-4-b.dtb /boot/

# Installation des modules
sudo cp -r lib/modules/* /lib/modules/

# Mise à jour des dépendances
sudo depmod -a

# Redémarrage
sudo reboot
```

## 🆘 Dépannage rapide

### Erreur Docker
- Vérifiez que Docker Desktop est démarré
- Redémarrez Docker Desktop si nécessaire

### Erreur de compilation
- Vérifiez l'espace disque (20 GB minimum)
- Augmentez la mémoire Docker si possible

### Problème de configuration
- Vérifiez que `configs/patchbox-config` existe
- Relancez le script d'extraction sur le Raspberry Pi

## 📞 Support

- **Documentation complète** : `README.md`
- **Vérification automatique** : `./scripts/verify-setup.sh`
- **Scripts de démarrage** : `start-build.bat` ou `start-build.ps1`

## ⏱️ Temps estimé

- **Construction Docker** : 5-10 minutes
- **Compilation du noyau** : 2-4 heures
- **Installation sur Pi** : 10-15 minutes

---

**🎉 Votre Raspberry Pi 4 aura bientôt un noyau Linux 6.12+ avec support real-time et reconnaissance du Touch Display 2 !**