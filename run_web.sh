#!/bin/bash
# ROOT FIX: Ensures localization files exist and persist through build

set -e

echo "🔧 Setting up web app..."

# Step 1: Ensure files are generated (pub get auto-generates with generate: true)
echo "📦 Getting dependencies (auto-generates localization files)..."
flutter pub get

# Step 2: Verify files exist
if [ ! -f "lib/l10n/app_localizations.dart" ]; then
    echo "⚠️  Files not auto-generated, generating manually..."
    flutter gen-l10n
fi

# Step 3: Wait and verify files persist
sleep 1
if [ ! -f "lib/l10n/app_localizations.dart" ]; then
    echo "❌ Files disappeared! Clean rebuild..."
    flutter clean
    flutter pub get
    flutter gen-l10n
    sleep 2
fi

# Final verification
if [ ! -f "lib/l10n/app_localizations.dart" ]; then
    echo "❌ CRITICAL: Cannot ensure localization files exist!"
    exit 1
fi

echo "✅ Localization files confirmed"
echo "🚀 Starting web app..."

# Let Flutter manage the build process (it will auto-generate if needed)
flutter run -d chrome --target=lib/main_web.dart
