#!/usr/bin/env bash
set -euo pipefail

# Configuration via environment variables
KERNEL_REPO=${KERNEL_REPO:-https://github.com/raspberrypi/linux.git}
KERNEL_BRANCH=${KERNEL_BRANCH:-rpi-6.12.y}
RT_VERSION=${RT_VERSION:-}
RT_URL=${RT_URL:-}
KERNEL_LOCALVERSION=${KERNEL_LOCALVERSION:--patchbox-rt}
ARCH=${ARCH:-arm64}
CROSS_COMPILE=${CROSS_COMPILE:-aarch64-linux-gnu-}
JOBS=${JOBS:-$(nproc)}

OUTPUT_DIR=/output
INPUT_DIR=/input
BUILD_DIR=/build
LINUX_DIR="${BUILD_DIR}/linux"

mkdir -p "${OUTPUT_DIR}" "${INPUT_DIR}" "${BUILD_DIR}"

echo "[+] Cloning kernel: ${KERNEL_REPO} (${KERNEL_BRANCH})"
if [[ ! -d "${LINUX_DIR}" ]]; then
  git clone --depth=1 --branch "${KERNEL_BRANCH}" "${KERNEL_REPO}" "${LINUX_DIR}"
else
  pushd "${LINUX_DIR}" >/dev/null
  git fetch --depth=1 origin "${KERNEL_BRANCH}"
  git checkout -f "${KERNEL_BRANCH}"
  git reset --hard "origin/${KERNEL_BRANCH}"
  popd >/dev/null
fi

pushd "${LINUX_DIR}" >/dev/null

KERNEL_VERSION_STR=$(make -s kernelversion || true)
echo "[+] Kernel version reported by tree: ${KERNEL_VERSION_STR}"

# Optionally fetch and apply PREEMPT_RT patch
if [[ -n "${RT_URL}" || -n "${RT_VERSION}" ]]; then
  if [[ -z "${RT_URL}" ]]; then
    # Try to construct the RT patch URL based on RT_VERSION
    # e.g. RT_VERSION=6.12.12-rt28
    MAJOR_MINOR=$(echo "${RT_VERSION}" | sed -E 's/^([0-9]+\.[0-9]+).*/\1/')
    CANDIDATE1="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${MAJOR_MINOR}/patch-${RT_VERSION}.patch.xz"
    CANDIDATE2="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${MAJOR_MINOR}/older/patch-${RT_VERSION}.patch.xz"
    for URL in "${CANDIDATE1}" "${CANDIDATE2}"; do
      echo "[+] Trying RT patch URL: ${URL}"
      if curl -fsSLI "${URL}" >/dev/null 2>&1; then
        RT_URL="${URL}"
        break
      fi
    done
  fi

  if [[ -z "${RT_URL}" ]]; then
    echo "[!] Unable to determine RT patch URL for RT_VERSION='${RT_VERSION}'. Skipping RT patch."
  else
    echo "[+] Downloading PREEMPT_RT patch: ${RT_URL}"
    curl -fsSL "${RT_URL}" -o /tmp/rt.patch.xz
    unxz -f /tmp/rt.patch.xz
    echo "[+] Applying PREEMPT_RT patch"
    if ! patch -p1 --forward < /tmp/rt.patch; then
      echo "[!] RT patch failed to apply cleanly. You may need a matching kernel branch or to resolve conflicts."
      exit 2
    fi
  fi
fi

# Seed configuration: prefer provided .config from host (Patchbox kernel config)
if [[ -f "${INPUT_DIR}/.config" ]]; then
  echo "[+] Using provided config from /input/.config"
  cp "${INPUT_DIR}/.config" .config
elif [[ -f "${INPUT_DIR}/config" ]]; then
  echo "[+] Using provided config from /input/config"
  cp "${INPUT_DIR}/config" .config
else
  echo "[+] No input config provided; using bcm2711_defconfig (Raspberry Pi 4/400)"
  make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" bcm2711_defconfig
fi

# Refresh configuration for this kernel tree
yes "" | make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" olddefconfig

# Ensure PREEMPT_RT if RT patch was applied or explicitly desired
if [[ -n "${RT_URL}" || -n "${RT_VERSION}" ]]; then
  echo "[+] Enabling CONFIG_PREEMPT_RT"
  scripts/config --enable PREEMPT_RT || true
  scripts/config --set-str LOCALVERSION "${KERNEL_LOCALVERSION}" || true
  yes "" | make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" olddefconfig
fi

# Ensure display stack relevant to Touch Display 2
echo "[+] Ensuring DRM VC4 and ILI9881D panel options are enabled"
scripts/config --module DRM_VC4 || true
scripts/config --module DRM_PANEL_ILITEK_ILI9881D || true
scripts/config --module DRM_SIMPLE_BRIDGE || true
scripts/config --module REGULATOR || true
scripts/config --module BACKLIGHT_CLASS_DEVICE || true
yes "" | make ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" olddefconfig

echo "[+] Starting kernel build (bindeb-pkg)"
make -j"${JOBS}" ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" LOCALVERSION="${KERNEL_LOCALVERSION}" bindeb-pkg

echo "[+] Collecting artifacts"
mkdir -p "${OUTPUT_DIR}/deb" "${OUTPUT_DIR}/dtbs" "${OUTPUT_DIR}/overlays"
find .. -maxdepth 1 -type f -name "*.deb" -print -exec cp -v {} "${OUTPUT_DIR}/deb/" \;

# Build DTBs and overlays if available (Raspberry Pi downstream kernel)
if grep -q "overlays" arch/arm/boot/dts/overlays/Makefile 2>/dev/null; then
  echo "[+] Building DTBs and overlays"
  make -j"${JOBS}" ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" dtbs
  make -j"${JOBS}" ARCH="${ARCH}" CROSS_COMPILE="${CROSS_COMPILE}" overlays || true
  if compgen -G "arch/arm/boot/dts/*.dtb" > /dev/null; then
    cp -v arch/arm/boot/dts/*.dtb "${OUTPUT_DIR}/dtbs/" || true
  fi
  if compgen -G "arch/arm/boot/dts/overlays/*.dtbo" > /dev/null; then
    cp -v arch/arm/boot/dts/overlays/*.dtbo "${OUTPUT_DIR}/overlays/" || true
    if [[ -f arch/arm/boot/dts/overlays/README ]]; then
      cp -v arch/arm/boot/dts/overlays/README "${OUTPUT_DIR}/overlays/README"
    fi
  fi
fi

echo "[+] Done. Artifacts in ${OUTPUT_DIR}"

popd >/dev/null

