# 🚀 Wassly Multi-App Setup Guide

## Overview

This project uses **Flutter Flavors** to generate 3 separate apps from one codebase:

| App | Package Name | Theme | Users |
|-----|-------------|-------|-------|
| **Customer** | `com.wassly.customer` | Orange | End users ordering food |
| **Partner** | `com.wassly.partner` | Green | Restaurants & Drivers |
| **Admin** | `com.wassly.admin` | Purple | System administrators |

---

## 🔥 Firebase Setup

### Option 1: Single Firebase Project (Recommended for MVP)

Use **ONE** Firebase project for all apps with role-based security rules.

#### Steps:

1. **Create ONE Firebase Project**
   ```
   Project Name: Wassly Production
   ```

2. **Add 3 Android Apps** (in Firebase Console):
   - `com.wassly.customer` → Download `google-services.json`
   - `com.wassly.partner` → Download `google-services.json`
   - `com.wassly.admin` → Download `google-services.json`

3. **Place Firebase Config Files**:
   ```bash
   # Customer app
   android/app/src/customer/google-services.json
   
   # Partner app
   android/app/src/partner/google-services.json
   
   # Admin app
   android/app/src/admin/google-services.json
   ```

4. **For iOS** (similar structure):
   ```bash
   ios/Customer/GoogleService-Info.plist
   ios/Partner/GoogleService-Info.plist
   ios/Admin/GoogleService-Info.plist
   ```

5. **Firestore Security Rules** (to restrict access by role):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       
       // Helper function to check user role
       function isAuthenticated() {
         return request.auth != null;
       }
       
       function getUserRole() {
         return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType;
       }
       
       function isCustomer() {
         return isAuthenticated() && getUserRole() == 'customer';
       }
       
       function isRestaurant() {
         return isAuthenticated() && getUserRole() == 'restaurant';
       }
       
       function isDriver() {
         return isAuthenticated() && getUserRole() == 'driver';
       }
       
       function isAdmin() {
         return isAuthenticated() && getUserRole() == 'admin';
       }
       
       // Users collection
       match /users/{userId} {
         allow read: if isAuthenticated();
         allow create: if isAuthenticated();
         allow update: if isAuthenticated() && request.auth.uid == userId;
         allow delete: if isAdmin();
       }
       
       // Restaurants collection
       match /restaurants/{restaurantId} {
         allow read: if true; // Public read
         allow create: if isRestaurant();
         allow update: if isRestaurant() && resource.data.ownerId == request.auth.uid;
         allow delete: if isAdmin();
       }
       
       // Products collection
       match /products/{productId} {
         allow read: if true; // Public read
         allow create, update: if isRestaurant();
         allow delete: if isRestaurant() || isAdmin();
       }
       
       // Orders collection
       match /orders/{orderId} {
         allow read: if isAuthenticated() && (
           resource.data.customerId == request.auth.uid ||
           resource.data.restaurantId in get(/databases/$(database)/documents/restaurants/$(request.auth.uid)).data ||
           resource.data.driverId == request.auth.uid ||
           isAdmin()
         );
         allow create: if isCustomer();
         allow update: if isRestaurant() || isDriver() || isAdmin();
         allow delete: if isAdmin();
       }
       
       // Drivers collection
       match /drivers/{driverId} {
         allow read: if isAuthenticated();
         allow create: if isDriver();
         allow update: if isDriver() && request.auth.uid == driverId;
         allow delete: if isAdmin();
       }
     }
   }
   ```

---

### Option 2: Separate Firebase Projects (Enterprise)

Create **3 separate** Firebase projects for complete isolation.

#### Projects:
1. **Wassly Customer** → `com.wassly.customer`
2. **Wassly Partner** → `com.wassly.partner`
3. **Wassly Admin** → `com.wassly.admin`

#### Pros:
- ✅ Complete data isolation
- ✅ Separate billing
- ✅ Different team access controls

#### Cons:
- ❌ More configuration
- ❌ Data synchronization challenges
- ❌ Higher maintenance

---

## 📱 Building & Running Apps

### Running in Development

```bash
# Run Customer App
flutter run --flavor customer --target lib/main_customer.dart

# Run Partner App
flutter run --flavor partner --target lib/main_partner.dart

# Run Admin App
flutter run --flavor admin --target lib/main_admin.dart
```

### Building Release APKs

```bash
# Build Customer App
flutter build apk --flavor customer --target lib/main_customer.dart --release

# Build Partner App
flutter build apk --flavor partner --target lib/main_partner.dart --release

# Build Admin App
flutter build apk --flavor admin --target lib/main_admin.dart --release
```

### Building App Bundles (for Play Store)

```bash
# Customer App
flutter build appbundle --flavor customer --target lib/main_customer.dart --release

# Partner App
flutter build appbundle --flavor partner --target lib/main_partner.dart --release

# Admin App
flutter build appbundle --flavor admin --target lib/main_admin.dart --release
```

### iOS Builds

```bash
# Customer App
flutter build ios --flavor customer --target lib/main_customer.dart --release

# Partner App
flutter build ios --flavor partner --target lib/main_partner.dart --release

# Admin App
flutter build ios --flavor admin --target lib/main_admin.dart --release
```

---

## 🎨 App Differentiation

### Visual Differences

| Feature | Customer | Partner | Admin |
|---------|----------|---------|-------|
| **Primary Color** | Orange (#FF6B35) | Green (#2E7D32) | Purple (#6A1B9A) |
| **App Name** | Wassly | Wassly Partner | Wassly Admin |
| **App Icon** | Shopping bag | Restaurant/Car | Dashboard |
| **Features** | Browse, Order, Track | Manage Orders, Deliver | Analytics, Manage All |

### App Icons

You can create different icons for each flavor:

```
android/app/src/customer/res/mipmap-*/ic_launcher.png
android/app/src/partner/res/mipmap-*/ic_launcher.png
android/app/src/admin/res/mipmap-*/ic_launcher.png
```

---

## 🔐 Authentication Flow by App

### Customer App
1. Sign up as Customer
2. Browse restaurants
3. Place orders
4. Track deliveries

### Partner App
1. Sign up as Restaurant or Driver
2. **If Restaurant**: Manage menu, accept orders
3. **If Driver**: Upload documents, accept deliveries
4. View earnings and analytics

### Admin App
1. Admin login only (no signup)
2. View all users, restaurants, orders
3. Approve/reject restaurants and drivers
4. System-wide analytics

---

## 📊 Database Structure (Shared)

All apps share the same Firestore database:

```
firestore/
├── users/              # All user types
├── restaurants/        # Restaurant profiles
├── products/           # Menu items
├── orders/             # All orders
├── drivers/            # Driver info & documents
├── reviews/            # Customer reviews
└── analytics/          # System metrics
```

**Access Control**: Managed by Firestore Security Rules

---

## 🛠️ VS Code Configuration

Create `.vscode/launch.json` for easy debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Customer App",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_customer.dart",
      "args": [
        "--flavor",
        "customer"
      ]
    },
    {
      "name": "Partner App",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_partner.dart",
      "args": [
        "--flavor",
        "partner"
      ]
    },
    {
      "name": "Admin App",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_admin.dart",
      "args": [
        "--flavor",
        "admin"
      ]
    }
  ]
}
```

---

## 🚀 Deployment Checklist

### Before Release:

- [ ] Update version in `pubspec.yaml`
- [ ] Test all 3 flavors thoroughly
- [ ] Configure signing keys for each flavor
- [ ] Test Firebase configurations
- [ ] Verify Firestore security rules
- [ ] Test on real devices
- [ ] Prepare Play Store/App Store listings
- [ ] Create separate listings for each app

### Play Store Listings:

1. **Wassly** (Customer)
   - Category: Food & Drink
   - Target: End consumers

2. **Wassly Partner** (Restaurant/Driver)
   - Category: Business
   - Target: Restaurant owners & delivery drivers

3. **Wassly Admin** (Admin)
   - Category: Internal tool (not public)
   - Or: Closed testing track

---

## 📦 APK Outputs

After building, find your APKs here:

```
build/app/outputs/flutter-apk/
├── app-customer-release.apk
├── app-partner-release.apk
└── app-admin-release.apk
```

---

## 🎯 Benefits of This Approach

### For Users:
- ✅ Smaller app sizes (only relevant features included)
- ✅ Cleaner, focused UI per user type
- ✅ Faster app performance

### For Development:
- ✅ Single codebase to maintain
- ✅ Shared models and business logic
- ✅ Fix bugs once, applies to all apps
- ✅ Consistent API integration

### For Business:
- ✅ Separate app store listings
- ✅ Different branding per user type
- ✅ Independent ratings and reviews
- ✅ Targeted marketing per app

---

## 🔥 Quick Start Commands

```bash
# Install dependencies
flutter pub get

# Run Customer app
flutter run --flavor customer -t lib/main_customer.dart

# Build all apps
./build_all_flavors.sh  # (create this script)
```

### Build Script (`build_all_flavors.sh`):

```bash
#!/bin/bash

echo "Building all Wassly apps..."

echo "Building Customer App..."
flutter build apk --flavor customer -t lib/main_customer.dart --release

echo "Building Partner App..."
flutter build apk --flavor partner -t lib/main_partner.dart --release

echo "Building Admin App..."
flutter build apk --flavor admin -t lib/main_admin.dart --release

echo "All apps built successfully!"
echo "APKs are in: build/app/outputs/flutter-apk/"
```

---

## 📞 Support

For issues with:
- **Flavors**: Check `android/app/build.gradle.kts`
- **Firebase**: Verify `google-services.json` placement
- **Routing**: Check `lib/core/router/*_router.dart`
- **Themes**: Check `lib/core/theme/*_theme.dart`

---

**🎉 You now have a production-ready multi-app architecture!**

