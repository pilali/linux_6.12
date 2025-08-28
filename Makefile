# Makefile pour la cross-compilation du noyau Linux 6.12 RT pour Raspberry Pi 4

.PHONY: build shell clean configure compile full-build help deploy-help

# Construction de l'image Docker
build:
	docker-compose build

# Lancement d'un shell interactif dans le container
shell: build
	docker-compose run --rm kernel-builder /bin/bash

# Configuration du noyau avec les paramètres PatchboxOS
configure:
	docker-compose run --rm kernel-builder /bin/bash -c "\
		cp /kernel-build/host/configure-patchbox-features.sh /kernel-build/ && \
		chmod +x /kernel-build/configure-patchbox-features.sh && \
		/kernel-build/configure-patchbox-features.sh"

# Compilation complète (téléchargement + patches + configuration + compilation)
full-build:
	docker-compose run --rm kernel-builder /bin/bash -c "\
		cp /kernel-build/host/build-kernel.sh /kernel-build/ && \
		cp /kernel-build/host/configure-patchbox-features.sh /kernel-build/ && \
		chmod +x /kernel-build/build-kernel.sh && \
		chmod +x /kernel-build/configure-patchbox-features.sh && \
		/kernel-build/build-kernel.sh && \
		/kernel-build/configure-patchbox-features.sh && \
		cd /kernel-build/linux-6.12 && \
		make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j\$$(nproc) && \
		make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules -j\$$(nproc) && \
		make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/kernel-build/output modules_install && \
		cp arch/arm64/boot/Image /kernel-build/output/kernel8.img && \
		cp arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /kernel-build/output/"

# Compilation rapide (suppose que les sources sont déjà préparées)
compile:
	docker-compose run --rm kernel-builder /bin/bash -c "\
		cd /kernel-build/linux-6.12 && \
		make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j\$$(nproc) && \
		make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules -j\$$(nproc) && \
		make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/kernel-build/output modules_install && \
		cp arch/arm64/boot/Image /kernel-build/output/kernel8.img && \
		cp arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /kernel-build/output/"

# Copie des fichiers de sortie vers l'hôte
copy-output:
	docker cp $$(docker-compose ps -q kernel-builder):/kernel-build/output ./output 2>/dev/null || \
	docker-compose run --rm kernel-builder /bin/bash -c "\
		mkdir -p /kernel-build/host/output && \
		cp -r /kernel-build/output/* /kernel-build/host/output/ 2>/dev/null || \
		echo 'Aucun fichier de sortie à copier'"

# Nettoyage
clean:
	docker-compose down -v
	docker system prune -f

# Aide
help:
	@echo "Commandes disponibles:"
	@echo "  make build        - Construire l'image Docker"
	@echo "  make shell        - Lancer un shell interactif"
	@echo "  make configure    - Configurer le noyau pour PatchboxOS"
	@echo "  make full-build   - Compilation complète (longue)"
	@echo "  make compile      - Compilation rapide"
	@echo "  make copy-output  - Copier les fichiers compilés vers l'hôte"
	@echo "  make clean        - Nettoyer les containers et volumes"
	@echo "  make deploy-help  - Afficher les instructions de déploiement"

# Instructions de déploiement
deploy-help:
	@echo "=== Instructions de déploiement sur Raspberry Pi 4 ==="
	@echo ""
	@echo "1. Copier les fichiers sur la carte SD:"
	@echo "   - Sauvegarder l'ancien noyau: sudo cp /boot/kernel8.img /boot/kernel8.img.backup"
	@echo "   - Copier le nouveau noyau: sudo cp output/kernel8.img /boot/"
	@echo "   - Copier le device tree: sudo cp output/bcm2711-rpi-4-b.dtb /boot/"
	@echo ""
	@echo "2. Installer les modules:"
	@echo "   - sudo cp -r output/lib/modules/* /lib/modules/"
	@echo "   - sudo depmod -a"
	@echo ""
	@echo "3. Configuration /boot/config.txt:"
	@echo "   - dtoverlay=vc4-kms-v3d"
	@echo "   - dtoverlay=rpi-ft5406"
	@echo "   - dtoverlay=pisound"
	@echo "   - disable_splash=1"
	@echo ""
	@echo "4. Redémarrer le Raspberry Pi"
	@echo ""
	@echo "5. Vérifier:"
	@echo "   - uname -a (version du noyau)"
	@echo "   - cat /sys/kernel/realtime (doit afficher 1)"
	@echo "   - aplay -l (vérifier Pisound)"
	@echo "   - dmesg | grep -i touch (vérifier écran tactile)"