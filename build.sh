#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Installing Flutter SDK on Vercel ==="
if [ ! -d "_flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
fi

export PATH="$PATH:`pwd`/_flutter/bin"

echo "=== Flutter Environment ==="
flutter --version

echo "=== Installing Dependencies ==="
flutter pub get

echo "=== Building Flutter Web Release ==="
flutter build web --release

echo "=== Build Complete ==="
