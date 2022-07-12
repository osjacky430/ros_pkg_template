#!/usr/bin/env bash
set -eou pipefail

VERSION="1.3.1"
MOLD_TAR_NAME="mold-${VERSION}-$(uname -m)-linux"
MIRROR_URL="https://github.com/rui314/mold/releases/download/v${VERSION}/${MOLD_TAR_NAME}.tar.gz"
DOWNLOAD_FILE="mold.tar.gz"

wget -nv -O "${DOWNLOAD_FILE}" "${MIRROR_URL}" -o /dev/null

tar -xf "${DOWNLOAD_FILE}"

mkdir -p /usr/local/libexec/ && mv ${MOLD_TAR_NAME}/libexec/mold /usr/local/libexec/mold
mkdir -p /usr/local/lib && mv ${MOLD_TAR_NAME}/lib/mold /usr/lib/mold
cp ${MOLD_TAR_NAME}/bin/* /usr/local/bin

# Cleanup
rm -rf "${DOWNLOAD_FILE}" "${MOLD_TAR_NAME}"