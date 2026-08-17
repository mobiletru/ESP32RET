#!/usr/bin/env bash
# Flash ESP32RET over USB with PlatformIO / esptool.
#
# Usage:
#   ./scripts/flash.sh [stable|stable-s3] [PORT]
#
# Examples:
#   ./scripts/flash.sh
#   ./scripts/flash.sh stable /dev/ttyUSB0
#   ./scripts/flash.sh stable-s3 /dev/ttyACM0
#
# This cloud environment has no USB serial device. Run the script on the
# machine that has the ESP32 plugged in.

set -euo pipefail

ENV="${1:-stable}"
PORT="${2:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ "$ENV" != "stable" && "$ENV" != "stable-s3" ]]; then
  echo "Unknown env '$ENV'. Use stable (ESP32 4MB) or stable-s3 (ESP32-S3 8MB)." >&2
  exit 1
fi

if ! command -v pio >/dev/null 2>&1; then
  echo "PlatformIO CLI not found. Installing with pip..."
  python3 -m pip install --user -q platformio
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if ! command -v pio >/dev/null 2>&1; then
  echo "pio is still not on PATH. Add ~/.local/bin to PATH and retry." >&2
  exit 1
fi

echo "Building and flashing env=$ENV${PORT:+ port=$PORT}"
pio device list || true

ARGS=(run -e "$ENV" -t upload)
if [[ -n "$PORT" ]]; then
  ARGS+=(--upload-port "$PORT")
fi

exec pio "${ARGS[@]}"
