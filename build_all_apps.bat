@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo    🚀 Wassly Multi-App Builder
echo ==========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Flutter is not installed or not in PATH
    exit /b 1
)

echo Flutter version:
flutter --version
echo.

set success_count=0
set total_count=3

REM Build Customer App
echo 🟠 Building Customer App...
flutter build apk --flavor customer --target lib/main_customer.dart --release
if %ERRORLEVEL% EQU 0 (
    echo ✅ Customer App built successfully!
    set /a success_count+=1
) else (
    echo ❌ Customer App build failed!
)
echo.

REM Build Partner App
echo 🟢 Building Partner App...
flutter build apk --flavor partner --target lib/main_partner.dart --release
if %ERRORLEVEL% EQU 0 (
    echo ✅ Partner App built successfully!
    set /a success_count+=1
) else (
    echo ❌ Partner App build failed!
)
echo.

REM Build Admin App
echo 🟣 Building Admin App...
flutter build apk --flavor admin --target lib/main_admin.dart --release
if %ERRORLEVEL% EQU 0 (
    echo ✅ Admin App built successfully!
    set /a success_count+=1
) else (
    echo ❌ Admin App build failed!
)
echo.

REM Summary
echo ==========================================
echo    📊 Build Summary
echo ==========================================
echo Total Apps: %total_count%
echo Successful: %success_count%
set /a failed_count=%total_count%-%success_count%
echo Failed: %failed_count%
echo.

if %success_count% EQU %total_count% (
    echo 🎉 All apps built successfully!
    echo.
    echo 📦 APKs are located in:
    echo    build\app\outputs\flutter-apk\
    echo.
    echo Files:
    echo    - app-customer-release.apk   ^(Customer App^)
    echo    - app-partner-release.apk    ^(Partner App^)
    echo    - app-admin-release.apk      ^(Admin App^)
) else (
    echo ⚠️  Some builds failed. Check the errors above.
    exit /b 1
)

echo.
echo ==========================================
pause

