#!/usr/bin/env bash
set -eou pipefail

MIRROR_URL="https://github.com/Kitware/CMake/releases/download/v3.23.2/cmake-3.23.2-linux-$(uname -m).sh"
DOWNLOAD_FILE="cmake.sh"

wget -nv -O "${DOWNLOAD_FILE}" "${MIRROR_URL}" -o /dev/null

# Install
bash "${DOWNLOAD_FILE}" --skip-license --prefix=/usr/local --exclude-subdir

# Cleanup
rm "${DOWNLOAD_FILE}"