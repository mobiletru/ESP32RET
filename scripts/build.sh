#!/usr/bin/env bash
# Compile ESP32RET firmware (does not flash).
#
# Usage:
#   ./scripts/build.sh [stable|stable-s3|all]

set -euo pipefail

ENV="${1:-stable}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v pio >/dev/null 2>&1; then
  echo "PlatformIO CLI not found. Installing with pip..."
  python3 -m pip install --user -q platformio
  export PATH="${HOME}/.local/bin:${PATH}"
fi

build_one() {
  local target="$1"
  echo "Building env=$target"
  pio run -e "$target"
  local out=".pio/build/${target}"
  echo "Firmware: ${out}/firmware.bin"
  ls -lh "${out}/firmware.bin" "${out}/bootloader.bin" "${out}/partitions.bin"
}

case "$ENV" in
  stable|stable-s3)
    build_one "$ENV"
    ;;
  all)
    build_one stable
    build_one stable-s3
    ;;
  *)
    echo "Unknown env '$ENV'. Use stable, stable-s3, or all." >&2
    exit 1
    ;;
esac
