#!/usr/bin/env bash
set -euo pipefail
mkdir -p assets/fonts assets/icon
FONT_PATH="$(fc-match -f '%{file}' 'Liberation Sans')"
if [ -z "$FONT_PATH" ]; then FONT_PATH="$(fc-match -f '%{file}' 'DejaVu Sans')"; fi
cp "$FONT_PATH" assets/fonts/DejaVuSans.ttf
convert -background none assets/icon/icon.svg assets/icon/icon.png
echo "Prepared Hebrew font: $FONT_PATH"
echo "Prepared launcher PNG: assets/icon/icon.png"
