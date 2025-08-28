FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    ARCH=arm64 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    JOBS=8

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates wget curl xz-utils rsync bc bison flex \
    build-essential fakeroot dpkg-dev libncurses5-dev libssl-dev libelf-dev \
    dwarves kmod python3 device-tree-compiler \
    crossbuild-essential-arm64 ccache \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy build script from the repository context
COPY scripts/build.sh /usr/local/bin/build-kernel
RUN chmod +x /usr/local/bin/build-kernel

ENTRYPOINT ["/usr/local/bin/build-kernel"]

