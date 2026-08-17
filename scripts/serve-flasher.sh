#!/usr/bin/env bash
# Serve the browser flasher on http://127.0.0.1:8789
# Open that URL in Chrome on the machine that has the ESP32 on USB.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${1:-8789}"

if [[ ! -f "$ROOT/.pio/build/stable/firmware.bin" ]]; then
  echo "Firmware not built yet. Building stable..."
  "$ROOT/scripts/build.sh" stable
fi

"$ROOT/scripts/package-flasher.sh"

echo "Browser flasher: http://127.0.0.1:${PORT}"
echo "Use Chrome or Edge. Click Connect, pick the ESP32 serial port, then Install."
cd "$ROOT/web-flasher"
exec python3 -m http.server "$PORT" --bind 127.0.0.1
