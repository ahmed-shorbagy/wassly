# Wassly Multi-App Architecture

## Project Structure for 3 Apps from One Codebase

```
wassly/
├── lib/
│   ├── main_customer.dart          # Entry point for Customer app
│   ├── main_partner.dart           # Entry point for Restaurant/Driver app
│   ├── main_admin.dart             # Entry point for Admin app
│   │
│   ├── core/                       # Shared across all apps
│   │   ├── constants/
│   │   │   ├── app_config.dart    # Flavor-specific configs
│   │   │   ├── app_colors.dart
│   │   │   └── app_strings.dart
│   │   ├── di/
│   │   │   ├── injection_container.dart
│   │   │   └── flavor_injector.dart  # Flavor-specific DI
│   │   ├── router/
│   │   │   ├── customer_router.dart
│   │   │   ├── partner_router.dart
│   │   │   └── admin_router.dart
│   │   ├── theme/
│   │   │   ├── customer_theme.dart
│   │   │   ├── partner_theme.dart
│   │   │   └── admin_theme.dart
│   │   └── utils/
│   │
│   ├── shared/                     # Shared models, widgets, logic
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── auth/                   # Shared auth (all apps)
│   │   │
│   │   ├── customer/               # Customer-only features
│   │   │   ├── restaurants/
│   │   │   ├── orders/
│   │   │   ├── cart/
│   │   │   └── profile/
│   │   │
│   │   ├── partner/                # Restaurant & Driver features
│   │   │   ├── restaurant_dashboard/
│   │   │   ├── products/
│   │   │   ├── orders/
│   │   │   ├── driver_dashboard/
│   │   │   ├── deliveries/
│   │   │   └── onboarding/
│   │   │
│   │   └── admin/                  # Admin-only features
│   │       ├── analytics/
│   │       ├── user_management/
│   │       ├── restaurant_approval/
│   │       ├── driver_verification/
│   │       └── system_settings/
│   │
│   └── config/
│       └── flavor_config.dart      # Flavor configuration
│
├── android/
│   └── app/
│       ├── src/
│       │   ├── customer/           # Customer app resources
│       │   │   ├── google-services.json
│       │   │   ├── res/
│       │   │   └── AndroidManifest.xml
│       │   ├── partner/            # Partner app resources
│       │   │   ├── google-services.json
│       │   │   ├── res/
│       │   │   └── AndroidManifest.xml
│       │   └── admin/              # Admin app resources
│       │       ├── google-services.json
│       │       ├── res/
│       │       └── AndroidManifest.xml
│       └── build.gradle.kts        # Flavor configuration
│
├── ios/
│   ├── Customer/                   # Customer app config
│   │   └── GoogleService-Info.plist
│   ├── Partner/                    # Partner app config
│   │   └── GoogleService-Info.plist
│   └── Admin/                      # Admin app config
│       └── GoogleService-Info.plist
│
└── firebase/
    ├── customer/                   # Customer Firebase project
    ├── partner/                    # Partner Firebase project
    └── admin/                      # Admin Firebase project
```

## Flavor Benefits

### Single Codebase Advantages:
- ✅ Shared models and business logic
- ✅ Single repository for version control
- ✅ Easier bug fixes (fix once, applies to all)
- ✅ Consistent API integration
- ✅ Reduced maintenance overhead

### Separate Apps:
- ✅ Different package names (separate Play Store/App Store listings)
- ✅ Different Firebase projects (isolated data if needed)
- ✅ Different branding and themes
- ✅ Role-specific features only
- ✅ Smaller app sizes (tree-shaking removes unused code)

## Build Commands

```bash
# Customer App
flutter run --flavor customer --target lib/main_customer.dart
flutter build apk --flavor customer --target lib/main_customer.dart

# Partner App (Restaurant/Driver)
flutter run --flavor partner --target lib/main_partner.dart
flutter build apk --flavor partner --target lib/main_partner.dart

# Admin App
flutter run --flavor admin --target lib/main_admin.dart
flutter build apk --flavor admin --target lib/main_admin.dart
```

## Firebase Strategy

### Option 1: Single Firebase Project (Recommended for MVP)
- One Firebase project for all apps
- Use Security Rules to restrict data access by user role
- Shared Firestore collections
- Role-based authentication

### Option 2: Separate Firebase Projects
- Different Firebase project for each app
- Complete data isolation
- More complex to maintain
- Better for enterprise/regulatory requirements

