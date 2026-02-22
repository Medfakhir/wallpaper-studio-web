#!/bin/bash
set -e

echo "🚀 Starting Flutter Web Build..."

# Check if Flutter is already installed
if ! command -v flutter &> /dev/null; then
    echo "📦 Installing Flutter..."
    
    # Clone Flutter SDK
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter
    
    # Add Flutter to PATH
    export PATH="$PATH:/opt/flutter/bin"
    
    # Disable analytics
    flutter config --no-analytics
    
    echo "✅ Flutter installed successfully"
else
    echo "✅ Flutter already installed"
fi

# Verify Flutter
echo "🔍 Flutter version:"
flutter --version

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build for web
echo "🏗️ Building for web..."
flutter build web --release

echo "✅ Build complete! Files are in build/web/"
