# 🚀 Quick Start: Admin Image Uploads

## What I Did for You

I've fully integrated Supabase into your Flutter app for image uploads. Everything is coded and ready to go. You just need to do **3 simple configuration steps** in the Supabase Dashboard.

---

## ⚡ What You Need to Do (15 minutes)

### Step 1: Add Supabase Credentials (2 minutes)

1. Open `lib/core/constants/supabase_constants.dart`
2. Replace these two lines:

```dart
static const String projectUrl = 'YOUR_SUPABASE_PROJECT_URL';
static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
```

**Where to get them:**
- Go to your Supabase project at [supabase.com](https://supabase.com)
- Click **Project Settings** (gear icon)
- Click **API** section
- Copy **URL** → paste as `projectUrl`
- Copy **anon public** key → paste as `anonKey`

---

### Step 2: Create Storage Buckets (5 minutes)

In your Supabase Dashboard:

1. Click **Storage** in the left sidebar
2. Click **"New bucket"** button
3. Create these 3 buckets:

| Bucket Name | Public? |
|-------------|---------|
| `restaurant-images` | ✅ Yes |
| `product-images` | ✅ Yes |
| `profile-images` | ✅ Yes |

**For each bucket:**
- Enter the exact name from table above
- Check the **"Public bucket"** checkbox
- Click **"Create bucket"**

---

### Step 3: Set Bucket Policies (8 minutes)

For **each bucket** you created (do this 3 times):

1. Click on the bucket name (e.g., `restaurant-images`)
2. Go to **Policies** tab
3. Click **"New Policy"** button
4. Select **"Get started quickly"** → **"Enable all operations"**
5. Click **"Use this template"**
6. Click **"Save policy"**

This gives public read/write access (good for testing).

> **Note:** For production, you'll want to restrict uploads to authenticated users only. We can configure that later.

---

### Step 4: Test It! (5 minutes)

```bash
# Run the admin app
flutter run -t lib/main_admin.dart
```

1. Navigate to **Create Restaurant** screen
2. Tap on "Tap to upload restaurant image"
3. Select any image
4. Fill in the form
5. Click **"Create Restaurant"**

**Expected result:**
- ✅ Image uploads to Supabase
- ✅ Restaurant created in Firestore with image URL
- ✅ Success message shown
- ✅ Image visible in your app

**Verify in Supabase:**
- Go to **Storage** → `restaurant-images` → `logos`
- Your image should be there!

---

## ✅ What's Already Implemented

### Code Changes Made:
1. ✅ Added `supabase_flutter` package to `pubspec.yaml`
2. ✅ Created `SupabaseService` for storage operations
3. ✅ Created `ImageUploadHelper` for easy uploads
4. ✅ Updated `RestaurantOwnerRepository` to use Supabase
5. ✅ Initialized Supabase in all main entry points
6. ✅ Added to dependency injection container
7. ✅ Created Supabase configuration constants
8. ✅ Updated admin repository to upload to Supabase instead of Firebase

### Architecture:
- ✅ Follows your MVVM + Clean Architecture
- ✅ Uses Cubit for state management
- ✅ Proper separation of concerns
- ✅ Dependency injection configured
- ✅ Error handling with Either<Failure, Success>

### Features Available:
- ✅ Pick image from gallery
- ✅ Upload to Supabase Storage
- ✅ Get public URL
- ✅ Save URL to Firestore
- ✅ Image validation (size, type)
- ✅ Loading states
- ✅ Error messages
- ✅ Success feedback

---

## 🎯 How It Works

```
[Admin App] 
    ↓
[Pick Image via Image Picker]
    ↓
[Upload to Supabase Storage] ← Your files (images)
    ↓
[Get Public URL]
    ↓
[Save Restaurant Data + Image URL to Firebase Firestore] ← Your data
    ↓
[Display in App using CachedNetworkImage]
```

**Key Point:** 
- **Images** stored in Supabase (fast, cheap, CDN)
- **Data** stored in Firebase Firestore (restaurant info, image URLs)
- **Auth** still uses Firebase (no changes)

---

## 📋 Configuration Checklist

- [ ] Step 1: Supabase credentials added
- [ ] Step 2: Created `restaurant-images` bucket
- [ ] Step 2: Created `product-images` bucket
- [ ] Step 2: Created `profile-images` bucket
- [ ] Step 3: Set policies for `restaurant-images`
- [ ] Step 3: Set policies for `product-images`
- [ ] Step 3: Set policies for `profile-images`
- [ ] Step 4: Tested restaurant creation with image
- [ ] ✅ Everything works!

---

## 🐛 Common Issues

### "Invalid project URL"
→ Check Step 1, make sure URL starts with `https://`

### "Bucket not found"
→ Double-check bucket name is exactly `restaurant-images` (with dash, not underscore)

### "Permission denied"
→ Make sure you did Step 3 for that specific bucket

### Image uploads but can't see it
→ Make sure bucket is marked as **Public** in Step 2

---

## 🎓 Usage Examples

### In Your Admin Screen (Already Working):

```dart
// This is already in create_restaurant_screen.dart
// Just showing you what's happening behind the scenes

// 1. User picks image
final image = await ImagePicker().pickImage(source: ImageSource.gallery);

// 2. Admin cubit creates restaurant
context.read<AdminCubit>().createRestaurant(
  imageFile: File(image.path),
  // ... other fields
);

// 3. Repository uploads to Supabase (automatic)
// 4. Saves to Firestore with image URL (automatic)
// 5. Success! ✨
```

### Want to Upload Products Too?

The code is ready! Just use:

```dart
import 'package:wassly/core/utils/image_upload_helper.dart';

// Upload a product image
final result = await ImageUploadQuickActions.uploadProductImage();

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (imageUrl) {
    // Save this URL with your product
    print('Product image uploaded: $imageUrl');
  },
);
```

### Want Multiple Images (Logo + Banner)?

Easy! Just call the upload twice:

```dart
// Upload logo
final logoResult = await ImageUploadQuickActions.uploadRestaurantLogo();

// Upload banner
final bannerResult = await ImageUploadQuickActions.uploadRestaurantBanner();

// Both URLs ready to save!
```

---

## 📖 Where to Look

### Configuration File:
`lib/core/constants/supabase_constants.dart` - Update your credentials here

### Service Layer:
`lib/core/network/supabase_service.dart` - Core upload functionality

### Helper Utilities:
`lib/core/utils/image_upload_helper.dart` - Easy-to-use upload methods

### Repository:
`lib/features/restaurants/data/repositories/restaurant_owner_repository_impl.dart` - Integration with your data layer

### Admin UI:
`lib/features/admin/presentation/views/create_restaurant_screen.dart` - The form you'll use

---

## 🎉 That's It!

Complete the 3 configuration steps above and you're done. The code is already integrated into your app following your clean architecture principles.

**Need more details?** Check the comprehensive guide: `ADMIN_IMAGE_UPLOAD_GUIDE.md`

**Questions?** All the code has detailed comments and logging. Check the console output when testing.

---

## 💡 Pro Tips

1. **Start with small images** (< 1MB) for your first test
2. **Check Supabase Dashboard** after upload to verify the file is there
3. **Watch the console logs** - They show every step clearly
4. **Test URL in browser** - Copy the URL from Firestore and paste in browser to verify it works
5. **Free tier limits** - Supabase free tier gives you 1GB storage and 2GB bandwidth per month

---

## 🔥 Ready to Go!

```bash
flutter run -t lib/main_admin.dart
```

Start creating restaurants with beautiful images! 📸🍕🍔

