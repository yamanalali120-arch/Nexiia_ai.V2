#!/bin/bash

# Flutter installieren
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Flutter Web Build ausführen
flutter config --enable-web
flutter pub get
flutter build web --web-renderer html --release
