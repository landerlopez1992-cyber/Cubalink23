#!/bin/bash

echo "🔄 Running Flutter compilation check..."
echo "Current directory: $(pwd)"

# Change to project directory
cd /hologram/data/project/turecarga

echo "📋 Flutter Doctor Check..."
flutter doctor --version

echo ""
echo "📊 Running flutter analyze..."
flutter analyze

echo ""
echo "🔍 Running dart analyze..."
dart analyze

echo ""
echo "🧹 Running flutter clean..."
flutter clean

echo ""
echo "📦 Running flutter pub get..."
flutter pub get

echo ""
echo "🏗️ Running flutter build check (dry run)..."
flutter build apk --debug --analyze-size

echo ""
echo "✅ Compilation check completed!"