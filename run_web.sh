#!/bin/bash
# Ultimate solution: Ensures localization files are generated before compilation

echo "🔧 Setting up web app..."

# Step 1: Clean and get dependencies (this should trigger generation)
echo "📦 Getting dependencies (triggers auto-generation)..."
flutter pub get

# Step 2: Explicitly generate localization files
echo "🌐 Explicitly generating localization files..."
flutter gen-l10n

# Step 3: Verify files exist before proceeding
if [ ! -f "lib/l10n/app_localizations.dart" ]; then
    echo "❌ ERROR: Localization files not generated!"
    echo "Attempting manual generation..."
    flutter pub get
    flutter gen-l10n
    sleep 2
    
    if [ ! -f "lib/l10n/app_localizations.dart" ]; then
        echo "❌ CRITICAL: Cannot generate localization files!"
        echo "Checking l10n configuration..."
        cat l10n.yaml
        exit 1
    fi
fi

echo "✅ Localization files confirmed at lib/l10n/app_localizations.dart"
echo "🚀 Starting web app..."

# Run the app - Flutter build system should preserve generated files
flutter run -d chrome --target=lib/main_web.dart
