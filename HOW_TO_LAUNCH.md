# 🚀 How to Launch Your Apps

## ✅ Setup Complete!

I've created launch configurations for both **VS Code** and **Android Studio/IntelliJ**.

---

## 📱 For VS Code Users

### Step 1: Open Run & Debug Panel
- Press `Ctrl+Shift+D` (Windows/Linux) or `Cmd+Shift+D` (Mac)
- Or click the "Run and Debug" icon in the left sidebar

### Step 2: Select Your App
You'll see a dropdown at the top with these options:

```
🟠 Customer App (Debug)       ← Orange theme, food ordering
🟠 Customer App (Release)
🟠 Customer App (Profile)

🟢 Partner App (Debug)        ← Green theme, restaurants/drivers
🟢 Partner App (Release)
🟢 Partner App (Profile)

🟣 Admin App (Debug)          ← Purple theme, administration
🟣 Admin App (Release)
🟣 Admin App (Profile)
```

### Step 3: Click the Play Button ▶️
- Or press `F5` to start debugging
- Your selected app will launch!

### Step 4: View in Device/Emulator
- The app will appear with the correct theme color
- Check the app name in the title bar

---

## 🔧 For Android Studio / IntelliJ Users

### Step 1: Look at the Top Toolbar
You'll see run configuration dropdown (top right area)

### Step 2: Select Configuration
Choose from:
- 🟠 Customer App
- 🟢 Partner App
- 🟣 Admin App

### Step 3: Click Run ▶️
- Or press `Shift+F10` (Windows/Linux)
- Or press `Control+R` (Mac)

---

## 🎨 Visual Differences You'll See

### Customer App (Orange)
```
App Bar: Orange background
Theme: Warm orange tones
Title: "Wassly"
Features: Browse restaurants, order food
```

### Partner App (Green)
```
App Bar: Green background
Theme: Professional green tones
Title: "Wassly Partner"
Features: Restaurant/Driver management
```

### Admin App (Purple)
```
App Bar: Purple background
Theme: Admin purple tones
Title: "Wassly Admin"
Features: System administration
```

---

## ⌨️ Keyboard Shortcuts

### VS Code
| Action | Windows/Linux | Mac |
|--------|---------------|-----|
| Start Debugging | `F5` | `F5` |
| Run Without Debugging | `Ctrl+F5` | `Cmd+F5` |
| Stop | `Shift+F5` | `Shift+F5` |
| Restart | `Ctrl+Shift+F5` | `Cmd+Shift+F5` |
| Open Debug Panel | `Ctrl+Shift+D` | `Cmd+Shift+D` |

### Android Studio
| Action | Windows/Linux | Mac |
|--------|---------------|-----|
| Run | `Shift+F10` | `Control+R` |
| Debug | `Shift+F9` | `Control+D` |
| Stop | `Ctrl+F2` | `Cmd+F2` |

---

## 🏗️ Build Tasks (VS Code)

### Access Tasks Menu
- Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
- Type "Tasks: Run Task"
- Select your task:

```
🧹 Flutter Clean               ← Clean and get packages
🔨 Build Customer APK (Debug)
🔨 Build Customer APK (Release)
🔨 Build Partner APK (Debug)
🔨 Build Partner APK (Release)
🔨 Build Admin APK (Debug)
🔨 Build Admin APK (Release)
📦 Build All Apps (Release)    ← Build all 3 at once!
📊 Flutter Analyze
🧪 Flutter Test
```

---

## 🎯 Quick Launch Commands

### Terminal Commands (if you prefer)

```bash
# Customer App
flutter run --flavor customer -t lib/main_customer.dart

# Partner App
flutter run --flavor partner -t lib/main_partner.dart

# Admin App
flutter run --flavor admin -t lib/main_admin.dart
```

### With Specific Device
```bash
# List devices
flutter devices

# Run on specific device
flutter run --flavor customer -t lib/main_customer.dart -d <device_id>
```

---

## 🐛 Debugging Tips

### Hot Reload
- Press `r` in the terminal while app is running
- Or save file in VS Code (auto hot reload)

### Hot Restart
- Press `R` in the terminal
- Or use `Ctrl+Shift+F5` in VS Code

### Flutter DevTools
- Press `Shift+P` → "Flutter: Open DevTools"
- Or visit the URL shown in terminal

### View Logs
- **VS Code**: Debug Console (bottom panel)
- **Android Studio**: Run tab (bottom)
- **Terminal**: Logs appear automatically

---

## 📦 Building Release APKs

### Via VS Code Tasks
1. `Ctrl+Shift+P` (Cmd+Shift+P on Mac)
2. "Tasks: Run Task"
3. Select "📦 Build All Apps (Release)"
4. Wait for builds to complete
5. Find APKs in: `build/app/outputs/flutter-apk/`

### Via Terminal
```bash
# Build all at once
flutter build apk --flavor customer -t lib/main_customer.dart --release && \
flutter build apk --flavor partner -t lib/main_partner.dart --release && \
flutter build apk --flavor admin -t lib/main_admin.dart --release

# Or one by one
flutter build apk --flavor customer -t lib/main_customer.dart --release
flutter build apk --flavor partner -t lib/main_partner.dart --release
flutter build apk --flavor admin -t lib/main_admin.dart --release
```

---

## 🔍 Troubleshooting

### "Flavor not found"
- Make sure you've run `flutter pub get`
- Check `android/app/build.gradle.kts` has flavor configuration

### "Cannot run multiple configurations"
- Stop the current app first (Shift+F5)
- Then start the new one

### "Wrong app launches"
- Check you selected the correct configuration from dropdown
- Verify the app name in the title bar matches

### "Build fails"
- Run "🧹 Flutter Clean" task first
- Then try building again

---

## ✨ Pro Tips

### 1. **Multiple Devices**
Run different apps on different devices simultaneously:
```bash
# Terminal 1
flutter run --flavor customer -t lib/main_customer.dart -d pixel

# Terminal 2
flutter run --flavor partner -t lib/main_partner.dart -d iphone
```

### 2. **Quick Switch**
In VS Code, press:
- `Ctrl+Shift+D` → Select app → `F5`
- Less than 3 seconds to switch apps!

### 3. **Profile Mode**
Use for performance testing:
```bash
flutter run --flavor customer -t lib/main_customer.dart --profile
```

### 4. **Build for Testing**
```bash
# Debug APK (faster, for testing)
flutter build apk --flavor customer -t lib/main_customer.dart --debug

# Release APK (for production)
flutter build apk --flavor customer -t lib/main_customer.dart --release
```

---

## 🎉 You're All Set!

Now you can easily launch any of your 3 apps with just a few clicks!

**Next Steps:**
1. Connect your device or start an emulator
2. Open VS Code Run & Debug panel (`Ctrl+Shift+D`)
3. Select your desired app from the dropdown
4. Click the Play button ▶️
5. Watch your app launch with the correct theme! 🚀

---

## 📞 Need Help?

If you encounter issues:
1. Check this guide first
2. Run `flutter doctor` to verify setup
3. Try "🧹 Flutter Clean" task
4. Restart your IDE

**Happy Coding! 🎨**

