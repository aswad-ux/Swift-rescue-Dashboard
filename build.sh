#!/bin/bash

# Vercel Build Script for Flutter Web

# 1. Download Flutter
echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 2. Get dependencies
echo "Getting dependencies..."
flutter pub get

# 3. Build the web app
echo "Building Flutter Web..."
flutter build web

echo "Build complete! Output is in build/web"
