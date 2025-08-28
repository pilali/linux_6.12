FROM ubuntu:22.04

# Éviter les interactions pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

# Mise à jour et installation des dépendances
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    bc \
    bison \
    flex \
    libssl-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libelf-dev \
    libdwarf-dev \
    dwarves \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    pkg-config \
    python3 \
    python3-pip \
    python3-dev \
    kmod \
    cpio \
    unzip \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Installation des outils de développement supplémentaires
RUN pip3 install --no-cache-dir \
    setuptools \
    wheel

# Création des répertoires de travail
RUN mkdir -p /workspace/{kernel,output,scripts,configs}

# Définition du répertoire de travail
WORKDIR /workspace

# Script d'initialisation
COPY scripts/init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

# Point d'entrée
ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["/bin/bash"]