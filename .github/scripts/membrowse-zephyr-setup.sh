#!/usr/bin/env bash
# Prepare fprime-zephyr-reference for MemBrowse memory analysis.
#
# Clones fprime-community/fprime-zephyr-reference next to this F´ checkout and
# installs the Python tools, west modules and Zephyr SDK (ARM toolchain only)
# needed to build its ReferenceDeployment. The build step copies this checkout
# into the reference project's lib/fprime (a symlink fails F´'s framework path
# check), see .github/membrowse-targets.json.
#
# Environment overrides:
#   ZEPHYR_REF_DIR     where to clone the reference project (default: ../fprime-zephyr-reference)
#   ZEPHYR_REF_BRANCH  branch of the reference project to build (default: devel)
#   ZEPHYR_SDK_DIR     install directory for the Zephyr SDK (default: west's default, ~/zephyr-sdk-<version>)
set -euo pipefail

FPRIME_DIR="$(git rev-parse --show-toplevel)"
REF_DIR="${ZEPHYR_REF_DIR:-${FPRIME_DIR}/../fprime-zephyr-reference}"
REF_BRANCH="${ZEPHYR_REF_BRANCH:-devel}"

rm -rf "${REF_DIR}"
git clone --depth 1 --branch "${REF_BRANCH}" https://github.com/fprime-community/fprime-zephyr-reference "${REF_DIR}"
git -C "${REF_DIR}" submodule update --init --depth 1 lib/fprime-zephyr
rsync -a --delete --exclude .git --exclude 'build-*' "${FPRIME_DIR}/" "${REF_DIR}/lib/fprime/"

cd "${REF_DIR}"
pip install west
west update --narrow -o=--depth=1
pip install -r requirements.txt
west sdk install -t arm-zephyr-eabi ${ZEPHYR_SDK_DIR:+-d "${ZEPHYR_SDK_DIR}"}
