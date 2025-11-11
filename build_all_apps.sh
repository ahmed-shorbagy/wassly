#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo "=========================================="
echo "   🚀 Wassly Multi-App Builder"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo "Flutter version:"
flutter --version
echo ""

# Function to build an app
build_app() {
    local flavor=$1
    local target=$2
    local color=$3
    local emoji=$4
    local name=$5
    
    echo -e "${color}${emoji} Building ${name}...${NC}"
    
    if flutter build apk --flavor "$flavor" --target "$target" --release; then
        echo -e "${GREEN}✅ ${name} built successfully!${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ ${name} build failed!${NC}"
        echo ""
        return 1
    fi
}

# Build counter
success_count=0
total_count=3

# Build Customer App
if build_app "customer" "lib/main_customer.dart" "$ORANGE" "🟠" "Customer App"; then
    ((success_count++))
fi

# Build Partner App
if build_app "partner" "lib/main_partner.dart" "$GREEN" "🟢" "Partner App"; then
    ((success_count++))
fi

# Build Admin App
if build_app "admin" "lib/main_admin.dart" "$PURPLE" "🟣" "Admin App"; then
    ((success_count++))
fi

# Summary
echo "=========================================="
echo "   📊 Build Summary"
echo "=========================================="
echo -e "Total Apps: ${total_count}"
echo -e "Successful: ${GREEN}${success_count}${NC}"
echo -e "Failed: ${RED}$((total_count - success_count))${NC}"
echo ""

if [ $success_count -eq $total_count ]; then
    echo -e "${GREEN}🎉 All apps built successfully!${NC}"
    echo ""
    echo "📦 APKs are located in:"
    echo "   build/app/outputs/flutter-apk/"
    echo ""
    echo "Files:"
    echo "   - app-customer-release.apk   (${ORANGE}Customer App${NC})"
    echo "   - app-partner-release.apk    (${GREEN}Partner App${NC})"
    echo "   - app-admin-release.apk      (${PURPLE}Admin App${NC})"
else
    echo -e "${RED}⚠️  Some builds failed. Check the errors above.${NC}"
    exit 1
fi

echo ""
echo "=========================================="

