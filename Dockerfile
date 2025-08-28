# Dockerfile pour cross-compilation du noyau Linux 6.12 RT pour Raspberry Pi 4
FROM ubuntu:22.04

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive

# Installation des dépendances de base
RUN apt-get update && apt-get install -y \
    build-essential \
    libncurses5-dev \
    libssl-dev \
    libelf-dev \
    bison \
    flex \
    bc \
    kmod \
    cpio \
    rsync \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    device-tree-compiler \
    u-boot-tools \
    && rm -rf /var/lib/apt/lists/*

# Installation du cross-compiler pour ARM64
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

# Variables d'environnement pour la cross-compilation
ENV ARCH=arm64
ENV CROSS_COMPILE=aarch64-linux-gnu-
ENV KERNEL=kernel8

# Création du répertoire de travail
WORKDIR /kernel-build

# Script d'entrée
COPY build-kernel.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/build-kernel.sh

CMD ["/bin/bash"]