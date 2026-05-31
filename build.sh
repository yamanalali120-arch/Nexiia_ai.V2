#!/usr/bin/env bash
set -euo pipefail

# Install Flutter SDK (not pre-installed on Vercel)
if [ ! -d "flutter" ]; then
  echo ">>> Cloning Flutter SDK (stable)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable
fi
export PATH="$PATH:$(pwd)/flutter/bin"

echo ">>> Flutter version:"
flutter --version

flutter config --enable-web

# Create placeholder .env if missing (listed as asset in pubspec.yaml,
# but not committed to git since it contains secrets).
# Vercel env vars should be configured in the Vercel Dashboard.
if [ ! -f ".env" ]; then
  echo ">>> Creating placeholder .env for Flutter asset bundling..."
  touch .env
fi

flutter pub get
flutter build web --release

# Verify build output
test -f build/web/index.html || { echo "Error: build/web/index.html not found"; exit 1; }
echo ">>> Build successful: build/web/index.html exists"
