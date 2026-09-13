#!/usr/bin/env bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UEFI_ROOT="$(cd "${PROJECT_ROOT}/.." && pwd)"
EDK2_ROOT="${UEFI_ROOT}/edk2"

if [[ ! -d "${EDK2_ROOT}" ]]; then
    echo "ERROR: EDK II directory not found:"
    echo "  ${EDK2_ROOT}"
    exit 1
fi

#
# Save command passed to this wrapper.
#
COMMAND=("$@")

if [[ ${#COMMAND[@]} -eq 0 ]]; then
    echo "Usage: $0 <command> [arguments...]"
    exit 1
fi

cd "${EDK2_ROOT}" || exit 1

#
# edksetup.sh parses positional parameters ($@).
# It must therefore be sourced with an empty argument list.
#
set --

source ./edksetup.sh || exit 1

export PACKAGES_PATH="${PROJECT_ROOT}:${EDK2_ROOT}"

#
# Execute original command inside prepared EDK II environment.
#
exec "${COMMAND[@]}"
