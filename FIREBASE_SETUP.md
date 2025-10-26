# Firebase Setup Instructions for Wassly

## Package Name: `com.wassly.app`

## Steps to Complete Firebase Setup

### 1. Download Firebase Config Files

#### For Android:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your Wassly project
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Click on the Android app (or add one if not exists)
6. Package name: `com.wassly.app`
7. Download `google-services.json`
8. Place it in: `android/app/google-services.json`

#### For iOS:
1. In Firebase Console, go to **Project Settings**
2. Under **Your apps**, add iOS app or click on existing one
3. Bundle ID: `com.wassly.app`
4. Download `GoogleService-Info.plist`
5. Place it in: `ios/Runner/GoogleService-Info.plist`

### 2. Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Enable **Email/Password**
5. Click **Save**

### 3. Create Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose your preferred location
5. Click **Enable**

### 4. Update Firebase Placeholder File
Replace the placeholder values in `android/app/google-services.json` with your actual Firebase configuration.

### 5. Test the Setup
Run the app and try to sign up to verify the Firebase connection is working.

## Important Notes
- The package name for both Android and iOS must be: `com.wassly.app`
- Make sure to enable Email/Password authentication
- Firestore database should be created before testing the app
- Keep the Firebase rules open for development but secure them before production
