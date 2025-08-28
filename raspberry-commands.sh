#!/bin/bash
# Script d'aide avec les commandes pré-configurées pour votre Raspberry Pi
# IP: 192.168.0.34, Utilisateur: patch

PI_IP="192.168.0.34"
PI_USER="patch"
PI_HOST="$PI_USER@$PI_IP"

echo "=== Commandes pour Raspberry Pi PatchboxOS ==="
echo "IP: $PI_IP"
echo "Utilisateur: $PI_USER"
echo ""

case "$1" in
    "get-config")
        echo "Récupération de la configuration PatchboxOS..."
        echo "Commandes à exécuter sur le Pi:"
        echo "  ssh $PI_HOST"
        echo "  sudo modprobe configs"
        echo "  zcat /proc/config.gz > /tmp/patchbox-config"
        echo ""
        echo "Puis sur votre PC:"
        echo "  scp $PI_HOST:/tmp/patchbox-config ./"
        ;;
    
    "deploy")
        echo "Déploiement du noyau compilé..."
        if [ ! -d "output" ]; then
            echo "Erreur: Dossier output/ non trouvé. Compilez d'abord avec 'make full-build'"
            exit 1
        fi
        
        echo "1. Copie des fichiers vers le Pi..."
        scp output/kernel8.img $PI_HOST:/tmp/
        scp output/bcm2711-rpi-4-b.dtb $PI_HOST:/tmp/
        
        if [ -d "output/lib/modules" ]; then
            echo "2. Copie des modules..."
            scp -r output/lib/modules/* $PI_HOST:/tmp/modules/
        fi
        
        echo ""
        echo "3. Connectez-vous au Pi et exécutez:"
        echo "  ssh $PI_HOST"
        echo "  sudo cp /boot/kernel8.img /boot/kernel8.img.backup"
        echo "  sudo cp /boot/bcm2711-rpi-4-b.dtb /boot/bcm2711-rpi-4-b.dtb.backup"
        echo "  sudo cp /tmp/kernel8.img /boot/"
        echo "  sudo cp /tmp/bcm2711-rpi-4-b.dtb /boot/"
        echo "  sudo cp -r /tmp/modules/* /lib/modules/"
        echo "  sudo depmod -a"
        echo "  sudo reboot"
        ;;
    
    "verify")
        echo "Vérification du système après redémarrage..."
        echo "Connectez-vous au Pi et exécutez:"
        echo "  ssh $PI_HOST"
        echo ""
        echo "Puis vérifiez:"
        echo "  uname -a                    # Version du noyau"
        echo "  cat /sys/kernel/realtime    # Support RT (doit afficher 1)"
        echo "  aplay -l                    # Périphériques audio"
        echo "  xinput list                 # Périphériques tactiles"
        echo "  dmesg | grep -i pisound     # Logs Pisound"
        echo "  dmesg | grep -i touch       # Logs écran tactile"
        ;;
    
    "backup")
        echo "Création d'une sauvegarde du système actuel..."
        echo "Commandes à exécuter sur le Pi:"
        echo "  ssh $PI_HOST"
        echo "  sudo cp /boot/kernel8.img /boot/kernel8.img.patchbox-original"
        echo "  sudo cp /boot/bcm2711-rpi-4-b.dtb /boot/bcm2711-rpi-4-b.dtb.original"
        echo "  sudo tar -czf /tmp/modules-backup.tar.gz /lib/modules/"
        echo ""
        echo "Pour récupérer la sauvegarde:"
        echo "  scp $PI_HOST:/tmp/modules-backup.tar.gz ./"
        ;;
    
    "restore")
        echo "Restauration de la sauvegarde..."
        echo "Commandes à exécuter sur le Pi:"
        echo "  ssh $PI_HOST"
        echo "  sudo cp /boot/kernel8.img.patchbox-original /boot/kernel8.img"
        echo "  sudo cp /boot/bcm2711-rpi-4-b.dtb.original /boot/bcm2711-rpi-4-b.dtb"
        echo "  sudo reboot"
        ;;
    
    "ssh")
        echo "Connexion SSH au Pi..."
        ssh $PI_HOST
        ;;
    
    *)
        echo "Usage: $0 {get-config|deploy|verify|backup|restore|ssh}"
        echo ""
        echo "Commandes disponibles:"
        echo "  get-config : Récupérer la configuration PatchboxOS"
        echo "  deploy     : Déployer le noyau compilé"
        echo "  verify     : Vérifier le système après installation"
        echo "  backup     : Sauvegarder le système actuel"
        echo "  restore    : Restaurer la sauvegarde"
        echo "  ssh        : Se connecter en SSH au Pi"
        echo ""
        echo "Exemple d'utilisation complète:"
        echo "  $0 get-config    # Récupérer la config actuelle"
        echo "  make full-build  # Compiler le noyau"
        echo "  $0 backup        # Sauvegarder le système"
        echo "  $0 deploy        # Déployer le nouveau noyau"
        echo "  $0 verify        # Vérifier que tout fonctionne"
        ;;
esac