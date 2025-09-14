#!/bin/bash

echo "============================================"
echo "🔧 FLUTTER PROJECT COMPILATION CHECK"
echo "============================================"

# Change to project directory
cd /hologram/data/project/turecarga

echo "📋 Step 1: Flutter Doctor"
echo "--------------------------------------------"
flutter doctor --version

echo ""
echo "📋 Step 2: Checking Flutter Dependencies"
echo "--------------------------------------------"
flutter pub get

echo ""
echo "📋 Step 3: Running Flutter Analyze (Static Analysis)"
echo "--------------------------------------------"
flutter analyze --fatal-infos --fatal-warnings

if [ $? -eq 0 ]; then
    echo "✅ Static analysis passed successfully!"
else
    echo "❌ Static analysis found issues!"
    exit 1
fi

echo ""
echo "📋 Step 4: Compilation Check (Dry Run)"
echo "--------------------------------------------"
flutter build apk --debug --dry-run

if [ $? -eq 0 ]; then
    echo "✅ Compilation check passed successfully!"
else
    echo "❌ Compilation check failed!"
    exit 1
fi

echo ""
echo "============================================"
echo "🎉 ALL CHECKS PASSED! PROJECT IS READY"
echo "============================================"