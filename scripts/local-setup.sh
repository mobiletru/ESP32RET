#!/usr/bin/env bash
# One-time local dev setup for building and flashing ESP32RET.
# Run this on the machine that has the ESP32 plugged in (Linux/macOS).
#
# Usage: ./scripts/local-setup.sh

set -uo pipefail

echo "== ESP32RET local dev setup =="

# 1. PlatformIO CLI
if command -v pio >/dev/null 2>&1; then
  echo "pio: $(pio --version)"
else
  echo "Installing PlatformIO CLI..."
  python3 -m pip install --user platformio || {
    echo "pip install failed. Install Python 3 first, then re-run." >&2
    exit 1
  }
  export PATH="${HOME}/.local/bin:${PATH}"
  echo "pio: $(pio --version)"
  echo "NOTE: add ~/.local/bin to PATH permanently (e.g. in ~/.bashrc)."
fi

OS="$(uname -s)"

# 2. Serial port permissions + udev rules (Linux only)
if [[ "$OS" == "Linux" ]]; then
  if [[ ! -f /etc/udev/rules.d/99-platformio-udev.rules ]]; then
    echo "Installing PlatformIO udev rules (needs sudo)..."
    curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules \
      | sudo tee /etc/udev/rules.d/99-platformio-udev.rules >/dev/null \
      && sudo udevadm control --reload-rules && sudo udevadm trigger \
      && echo "udev rules installed." \
      || echo "Could not install udev rules; flashing may still work as root."
  else
    echo "udev rules: already installed."
  fi

  if id -nG "$USER" | grep -qw dialout; then
    echo "dialout group: OK"
  else
    echo "Adding $USER to dialout group (needs sudo)..."
    sudo usermod -aG dialout "$USER" \
      && echo "Added. Log out and back in for it to take effect." \
      || echo "Could not add to dialout; you may need sudo to flash."
  fi
elif [[ "$OS" == "Darwin" ]]; then
  echo "macOS: no udev/group setup needed."
  echo "If the board does not enumerate, install the CP210x or CH340 USB driver."
fi

# 3. Detect the board
echo
echo "Serial devices:"
pio device list 2>/dev/null || ls /dev/ttyUSB* /dev/ttyACM* /dev/cu.* 2>/dev/null || true

FOUND=""
for p in /dev/ttyUSB0 /dev/ttyACM0 /dev/cu.usbserial* /dev/cu.usbmodem*; do
  [[ -e "$p" ]] && FOUND="$p" && break
done

echo
if [[ -n "$FOUND" ]]; then
  echo "Board detected on $FOUND. Flash with:"
  echo "  ./flash                 # classic ESP32"
  echo "  ./flash stable-s3       # ESP32-S3"
else
  echo "No ESP32 detected yet. Plug the board in, then run:"
  echo "  ./flash"
fi
echo
echo "No-toolchain alternative: cd web-flasher && python3 -m http.server 8789"
echo "then open http://127.0.0.1:8789 in Chrome and click Install."
