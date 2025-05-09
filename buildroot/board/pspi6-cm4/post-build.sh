#!/bin/sh

set -u
set -e

echo "[PSPi6] Starting post-image script..."
echo "[PSPi6] ################################################################################"
echo "[PSPi6] ###                                                                          ###"
echo "[PSPi6] ###  The following section provides all the necessary Drivers, Overlays      ###"
echo "[PSPi6] ###    and Services required by the PSPi6 board.                             ###"
echo "[PSPi6] ###                                                                          ###"
echo "[PSPi6] ###    • PSPi6 developed by Othermod                                         ###"
echo "[PSPi6] ###       - https://github.com/othermod/PSPi-Version-6                       ###"
echo "[PSPi6] ###    • Package maintained by zelda42                                       ###"
echo "[PSPi6] ###       - https://ultra64.ca                                               ###"
echo "[PSPi6] ###                                                                          ###"
echo "[PSPi6] ################################################################################"

# Variables
PSPI_TMP="${BUILD_DIR}/pspi6-tmp"
echo "[PSPi6] Using PSPI_TMP: $PSPI_TMP"
PSPI_DL="${BUILD_DIR}/pspi6-dl"
echo "[PSPi6] Using PSPI_DL: $PSPI_DL"
PSPI_DL_URL="https://github.com/othermod/PSPi-Version-6/archive/refs/heads/main.zip"
echo "[PSPi6] Using PSPI_DL_URL: $PSPI_DL_URL"
PSPI_DL_NAME="pspi6-version-6-main.zip"
echo "[PSPi6] Using PSPI_DL_NAME: $PSPI_DL_NAME"
PSPI_DL_FILE="${PSPI_DL}/${PSPI_DL_NAME}"
echo "[PSPi6] Using PSPI_DL_FILE: $PSPI_DL_FILE"
PSPI_DL_EXTRACTED="${PSPI_TMP}/PSPi-Version-6-main/rpi"
echo "[PSPi6] Using PSPI_DL_EXTRACTED: $PSPI_DL_EXTRACTED"

# 1. Download zip if not cached
if [ ! -f "$PSPI_DL_FILE" ]; then
    echo "[PSPi6] Downloading PSPi6 support files..."
	mkdir -p "$PSPI_DL"
    wget -O "$PSPI_DL_FILE" "$PSPI_DL_URL"
else
    echo "[PSPi6] Using cached PSPi6 zip from dl/"
fi

# 2. Unzip cleanly
rm -rf "$PSPI_TMP"
mkdir -p "$PSPI_TMP"

echo "[PSPi6] Extracting PSPi6 archive..."

PSPI_TMP="${BUILD_DIR}/pspi6-tmp"
echo "[PSPi6] Using PSPI_TMP: $PSPI_TMP"

PSPI_DL_FILE="${PSPI_DL}/${PSPI_DL_NAME}"
echo "[PSPi6] Using PSPI_DL_FILE: $PSPI_DL_FILE"

unzip -q "$PSPI_DL_FILE" -d "$PSPI_TMP"

# 3. Copy overlays to boot firmware (rpi-firmware overlays directory)
OVERLAYS_SRC="${PSPI_DL_EXTRACTED}/overlays"
OVERLAYS_DST="${BINARIES_DIR}/rpi-firmware/overlays"
if [ -d "$OVERLAYS_SRC" ]; then
    echo "[PSPi6] Copying overlays..."
	mkdir -p "$OVERLAYS_DST"
    cp -rv "$OVERLAYS_SRC/"* "$OVERLAYS_DST/"
else
    echo "[PSPi6] Warning: overlays folder not found!"
fi

# 4. Copy services into systemd on target
SERVICES_SRC="${PSPI_DL_EXTRACTED}/services"
SERVICES_DST="${TARGET_DIR}/etc/systemd/system"
if [ -d "$SERVICES_SRC" ]; then
    echo "[PSPi6] Copying systemd services..."
    mkdir -p "$SERVICES_DST"
    cp -rv "$SERVICES_SRC/"* "$SERVICES_DST/"
else
    echo "[PSPi6] Warning: services folder not found!"
fi

# 5. Optional: copy drivers (if you want to compile or load them manually later)
DRIVERS_SRC="${PSPI_DL_EXTRACTED}/drivers"
DRIVERS_DST="${TARGET_DIR}/lib/modules/pspi6-drivers"
if [ -d "$DRIVERS_SRC" ]; then
    echo "[PSPi6] Copying drivers..."
    mkdir -p "$DRIVERS_DST"
    cp -rv "$DRIVERS_SRC/"* "$DRIVERS_DST/"
else
    echo "[PSPi6] Warning: drivers folder not found!"
fi

echo "[PSPi6] post-image.sh completed successfully!"

################################################################################

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
# systemd doesn't use /etc/inittab, enable getty.tty1.service instead
elif [ -d ${TARGET_DIR}/etc/systemd ]; then
    mkdir -p "${TARGET_DIR}/etc/systemd/system/getty.target.wants"
    ln -sf /lib/systemd/system/getty@.service \
       "${TARGET_DIR}/etc/systemd/system/getty.target.wants/getty@tty1.service"
fi
