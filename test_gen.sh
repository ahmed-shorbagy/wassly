#!/bin/bash
flutter gen-l10n
sleep 1
if [ -f lib/l10n/app_localizations.dart ]; then
    echo "SUCCESS"
else
    echo "FAILED"
fi
