#!/usr/bin/env bash
# Copy built firmware into web-flasher/ for the browser installer.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/web-flasher/firmware"
BOOT_APP0="$(find "${HOME}/.platformio/packages" -path '*framework-arduinoespressif32*/tools/partitions/boot_app0.bin' 2>/dev/null | head -n 1 || true)"

copy_env() {
  local env="$1"
  local src="$ROOT/.pio/build/${env}"
  local dest="$OUT/${env}"
  if [[ ! -f "$src/firmware.bin" ]]; then
    echo "Missing $src/firmware.bin — run ./scripts/build.sh $env first." >&2
    return 1
  fi
  mkdir -p "$dest"
  cp -f "$src/firmware.bin" "$src/bootloader.bin" "$src/partitions.bin" "$dest/"
  if [[ -n "$BOOT_APP0" ]]; then
    cp -f "$BOOT_APP0" "$dest/boot_app0.bin"
  fi
  echo "Packaged $env -> $dest"
}

copy_env stable
copy_env stable-s3 || true

cat > "$ROOT/web-flasher/manifest.json" <<'EOF'
{
  "name": "ESP32RET",
  "version": "618",
  "new_install_prompt_erase": true,
  "new_install_improv_wait_time": 0,
  "builds": [
    {
      "chipFamily": "ESP32",
      "parts": [
        { "path": "firmware/stable/bootloader.bin", "offset": 4096 },
        { "path": "firmware/stable/partitions.bin", "offset": 32768 },
        { "path": "firmware/stable/boot_app0.bin", "offset": 57344 },
        { "path": "firmware/stable/firmware.bin", "offset": 65536 }
      ]
    },
    {
      "chipFamily": "ESP32-S3",
      "parts": [
        { "path": "firmware/stable-s3/bootloader.bin", "offset": 0 },
        { "path": "firmware/stable-s3/partitions.bin", "offset": 32768 },
        { "path": "firmware/stable-s3/boot_app0.bin", "offset": 57344 },
        { "path": "firmware/stable-s3/firmware.bin", "offset": 65536 }
      ]
    }
  ]
}
EOF

echo "Wrote $ROOT/web-flasher/manifest.json"
