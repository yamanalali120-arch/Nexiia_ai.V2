#!/usr/bin/env bash
set -euo pipefail

# Ensure Flutter SDK in PATH (assumes flutter is already installed globally)
# If not, you can add flutter bin to PATH here.

flutter config --enable-web
flutter doctor
flutter pub get
flutter build web --release

# Verify build output
test -f build/web/index.html || { echo "Error: build/web/index.html not found"; exit 1; }
