plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.wassly.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Default application ID (will be overridden by flavors)
        applicationId = "com.wassly.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Define product flavors for Customer, Partner, and Admin apps
    flavorDimensions += "app"
    productFlavors {
        create("customer") {
            dimension = "app"
            applicationId = "com.wassly.customer"
            resValue("string", "app_name", "Wassly")
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_customer"
        }
        
        create("partner") {
            dimension = "app"
            applicationId = "com.wassly.partner"
            resValue("string", "app_name", "Wassly Partner")
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_partner"
        }
        
        create("admin") {
            dimension = "app"
            applicationId = "com.wassly.admin"
            resValue("string", "app_name", "Wassly Admin")
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_admin"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
