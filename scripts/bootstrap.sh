#!/usr/bin/env bash

set -euo pipefail

EDK2_REPOSITORY="https://github.com/tianocore/edk2.git"
EDK2_COMMIT="cd2a06cd310b1e5b504a9d55e6b42e4d14681e34"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARENT_ROOT="$(cd "${PROJECT_ROOT}/.." && pwd)"
EDK2_ROOT="${PARENT_ROOT}/edk2"

log() {
    printf '\n==> %s\n' "$*"
}

log "Project root: ${PROJECT_ROOT}"
log "EDK II root:  ${EDK2_ROOT}"

log "Installing host dependencies"

sudo apt update

sudo apt install -y \
    build-essential \
    git \
    git-lfs \
    python3 \
    python3-pip \
    python3-setuptools \
    uuid-dev \
    nasm \
    acpica-tools \
    qemu-system-x86 \
    qemu-utils

log "Host tool versions"

gcc --version | head -n 1
make --version | head -n 1
python3 --version
nasm -v
iasl -v | head -n 1
qemu-system-x86_64 --version | head -n 1
git --version

if [[ -e "${EDK2_ROOT}" && ! -d "${EDK2_ROOT}/.git" ]]; then
    echo "ERROR: ${EDK2_ROOT} already exists but is not a Git repository." >&2
    echo "Move/remove it, or place this project next to a valid edk2 checkout." >&2
    exit 1
fi

if [[ ! -d "${EDK2_ROOT}/.git" ]]; then
    log "Cloning EDK II into sibling directory"
    git clone "${EDK2_REPOSITORY}" "${EDK2_ROOT}"
else
    log "Existing EDK II checkout found"
fi

cd "${EDK2_ROOT}"

log "Fetching EDK II revision"
git fetch --all --tags

log "Checking out EDK II commit ${EDK2_COMMIT}"
git checkout "${EDK2_COMMIT}"

log "Updating EDK II submodules"
git submodule update --init --recursive

log "Building EDK II BaseTools"
make -C BaseTools

log "Verifying EDK II environment"

# edksetup.sh reads positional parameters from the current shell.
# Ensure it sees an empty argument list.
set --
source ./edksetup.sh

if ! command -v build >/dev/null 2>&1; then
    echo "ERROR: EDK II 'build' command is not available after edksetup.sh." >&2
    exit 1
fi

printf 'WORKSPACE=%s\n' "${WORKSPACE:-}"
printf 'EDK_TOOLS_PATH=%s\n' "${EDK_TOOLS_PATH:-}"
printf 'build=%s\n' "$(command -v build)"

log "Bootstrap completed successfully"

echo
printf 'Directory layout:\n'
printf '  %s/\n' "${PARENT_ROOT}"
printf '  ├── edk2/\n'
printf '  └── %s/\n' "$(basename "${PROJECT_ROOT}")"

echo
printf 'Build firmware:\n'
printf '  cd "%s"\n' "${PROJECT_ROOT}"
printf '  make build\n'

echo
printf 'Build and run in QEMU:\n'
printf '  make run\n'
