# My UEFI Firmware

Educational UEFI firmware project based on EDK II / OVMF.

The project builds a complete UEFI firmware image for QEMU pflash. It is **not** an EFI application.

## What is custom here?

The output is a complete firmware image, but most of the firmware stack currently comes from upstream EDK II / OVMF.

Project-owned parts currently include:

- `MyUefiFwPkg/MyUefiFw.dsc` — platform composition;
- `MyUefiFwPkg/MyUefiFw.fdf` — flash / firmware volume layout;
- `MyUefiFwPkg/MyUefiFwPkg.dec` — package declaration;
- `HelloDxe` — custom DXE driver.

EDK II / OVMF currently provides most of SEC, PEI, DXE Core, BDS, memory/platform initialization and standard device drivers.

So the build result is a **full firmware image**, while the amount of firmware code implemented directly in this repository is intentionally small for now.

## Directory layout

The absolute path does not matter. The only requirement is that `edk2` and this repository are sibling directories:

```text
<any-directory>/
├── edk2/
└── my-uefi-fw/
```

All project scripts resolve paths relative to the repository location.

## Supported host

Tested on Ubuntu 24.04 LTS.

## Quick start

Install Git, clone this repository anywhere, then run the bootstrap script:

```bash
sudo apt update
sudo apt install -y git

mkdir -p ~/projects/firmware
cd ~/projects/firmware

git clone <YOUR_REPOSITORY_URL> my-uefi-fw
cd my-uefi-fw

./scripts/bootstrap.sh
make run
```

`bootstrap.sh` will:

1. install required host packages;
2. clone EDK II into `../edk2` if needed;
3. checkout the pinned EDK II revision;
4. initialize submodules;
5. build EDK II BaseTools;
6. verify the EDK II build environment.

## Pinned EDK II revision

```text
cd2a06cd310b1e5b504a9d55e6b42e4d14681e34
```

Do not assume that an arbitrary newer EDK II `master` revision is compatible with this project.

## Manual environment preparation

Install dependencies:

```bash
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
```

Clone and prepare EDK II next to this repository:

```bash
cd ..
git clone https://github.com/tianocore/edk2.git
cd edk2

git checkout cd2a06cd310b1e5b504a9d55e6b42e4d14681e34
git submodule update --init --recursive
make -C BaseTools
```

Optional environment check:

```bash
source edksetup.sh

echo "$WORKSPACE"
which build
```

Normal project builds do not require manually sourcing `edksetup.sh`.

## Optional: verify upstream OVMF

Use this to separate host/toolchain problems from project problems:

```bash
cd ../edk2
source edksetup.sh

build \
    -a X64 \
    -t GCC \
    -p OvmfPkg/OvmfPkgX64.dsc \
    -b DEBUG
```

Expected firmware artifacts are under:

```text
Build/OvmfX64/DEBUG_GCC/FV/
```

## Build

From the project root:

```bash
make
```

or:

```bash
make build
```

Final artifacts are exported to:

```text
build/
├── MYUEFIFW.fd
├── MYUEFIFW_CODE.fd
└── MYUEFIFW_VARS.fd
```

EDK II intermediate output remains under:

```text
../edk2/Build/MyUefiFw/
```

## Run in QEMU

```bash
make run
```

QEMU uses:

```text
build/MYUEFIFW_CODE.fd
build/MYUEFIFW_VARS.runtime.fd
```

The CODE image is read-only. The runtime VARS image is writable and persists UEFI variables between runs.

Debug output:

```text
build/debug.log
```

Example:

```bash
grep HelloDxe build/debug.log
```

Reset runtime NVRAM:

```bash
make reset-vars
```

## Clean

```bash
make clean
make distclean
```

`clean` removes project-visible build artifacts. `distclean` also removes this platform's EDK II intermediate build output.

## VSCode

Open the multi-root workspace:

```bash
code my-uefi-fw.code-workspace
```

It contains both `MyUefiFw` and `EDK2`, allowing navigation into EDK II headers, protocols, libraries and platform code.

Recommended extension:

```text
ms-vscode.cpptools
```

Build with `Ctrl+Shift+B`.

## Development model

```text
edit custom module / platform files
        ↓
make run
        ↓
EDK II + OVMF components + project components
        ↓
complete MYUEFIFW firmware image
        ↓
QEMU pflash
```

For interactive EDK II shell work, use:

```bash
source scripts/env.sh
```
