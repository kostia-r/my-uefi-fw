#!/usr/bin/env bash

# This script must be sourced, not executed.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UEFI_ROOT="$(cd "${PROJECT_ROOT}/.." && pwd)"
EDK2_ROOT="${UEFI_ROOT}/edk2"

if [[ ! -d "${EDK2_ROOT}" ]]; then
    echo "ERROR: edk2 not found: ${EDK2_ROOT}"
    return 1 2>/dev/null || exit 1
fi

export MY_UEFI_FW_ROOT="${PROJECT_ROOT}"
export EDK2_ROOT="${EDK2_ROOT}"

cd "${EDK2_ROOT}" || return 1

source ./edksetup.sh

export PACKAGES_PATH="${PROJECT_ROOT}:${EDK2_ROOT}"

cd "${PROJECT_ROOT}" || return 1

echo "MY_UEFI_FW_ROOT=${MY_UEFI_FW_ROOT}"
echo "EDK2_ROOT=${EDK2_ROOT}"
echo "WORKSPACE=${WORKSPACE}"
echo "PACKAGES_PATH=${PACKAGES_PATH}"

