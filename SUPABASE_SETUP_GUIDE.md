# Supabase Integration Guide

## Overview
This project uses **Supabase Storage** for uploading and managing images and files, while keeping **Firebase** for authentication and database operations. Both services work seamlessly together.

## ✅ What's Already Done

### 1. Package Installation
- ✅ `supabase_flutter: ^2.5.0` added to `pubspec.yaml`

### 2. Configuration Files Created
- ✅ `lib/core/constants/supabase_constants.dart` - Configuration constants
- ✅ `lib/core/network/supabase_service.dart` - Main storage service
- ✅ `lib/core/utils/image_upload_helper.dart` - Helper utilities for image uploads

### 3. Initialization
- ✅ Supabase initialized in all main entry points:
  - `lib/main.dart`
  - `lib/main_admin.dart`
  - `lib/main_customer.dart`
  - `lib/main_partner.dart`

### 4. Dependency Injection
- ✅ `SupabaseService` and `ImageUploadHelper` added to `InjectionContainer`

---

## 🚀 Quick Start

### Step 1: Add Your Supabase Credentials

Open `lib/core/constants/supabase_constants.dart` and replace the placeholder values:

```dart
/// Supabase Project URL
static const String projectUrl = 'https://YOUR_PROJECT.supabase.co';

/// Supabase Anonymous Key (Public Key)
static const String anonKey = 'YOUR_ANON_KEY_HERE';
```

**Where to find these:**
1. Go to [supabase.com](https://supabase.com) and open your project
2. Navigate to: **Project Settings** → **API**
3. Copy:
   - **URL** (Project URL)
   - **anon/public** key (anon key)

### Step 2: Create Storage Buckets in Supabase Dashboard

1. In your Supabase project, go to **Storage** in the sidebar
2. Create the following buckets:
   - `restaurant-images` - For restaurant logos and banners
   - `product-images` - For product photos
   - `profile-images` - For user profile pictures
   - `uploads` - For general uploads

**Important:** Set bucket policies for each bucket:
- For testing: Make buckets **public** (anyone can read/write)
- For production: Set proper RLS policies (authenticated users only)

#### Quick Public Policy (for testing):
For each bucket, go to **Policies** and add:
- **Policy name:** "Public Access"
- **Allowed operations:** SELECT, INSERT, UPDATE, DELETE
- **Policy definition:** `true` (allows all)

> ⚠️ **Security Note:** For production, implement proper authentication-based policies!

### Step 3: Run Flutter Pub Get

```bash
flutter pub get
```

### Step 4: Verify Installation

Run your app. Check the console logs for:
```
✅ Firebase initialized
✅ Supabase initialized
✅ Dependency injection initialized
```

---

## 📖 Usage Examples

### Example 1: Upload Restaurant Logo (Simplest Way)

```dart
import 'package:wassly/core/utils/image_upload_helper.dart';

// In your Cubit or ViewModel
Future<void> uploadLogo() async {
  final result = await ImageUploadQuickActions.uploadRestaurantLogo();
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (imageUrl) {
      print('Image uploaded: $imageUrl');
      // Save imageUrl to Firebase Firestore
    },
  );
}
```

### Example 2: Upload Product Image with Custom Logic

```dart
import 'dart:io';
import 'package:wassly/core/di/injection_container.dart';
import 'package:wassly/core/constants/supabase_constants.dart';

// In your Cubit
class ProductManagementCubit extends Cubit<ProductManagementState> {
  final imageHelper = InjectionContainer().imageUploadHelper;
  
  Future<void> uploadProductImage() async {
    emit(ProductUploadingState());
    
    final result = await imageHelper.pickAndUploadImage(
      bucketName: SupabaseConstants.productImagesBucket,
      folder: SupabaseConstants.productPhotosFolder,
    );
    
    result.fold(
      (failure) => emit(ProductUploadErrorState(failure.message)),
      (imageUrl) {
        // Save imageUrl to Firestore
        emit(ProductUploadedState(imageUrl));
      },
    );
  }
}
```

### Example 3: Upload Multiple Product Images

```dart
Future<void> uploadMultipleProductImages() async {
  final result = await ImageUploadQuickActions.uploadProductImages(
    maxImages: 5,
  );
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (imageUrls) {
      print('${imageUrls.length} images uploaded');
      // Save imageUrls list to Firestore
    },
  );
}
```

### Example 4: Camera Capture and Upload

```dart
import 'package:image_picker/image_picker.dart';

Future<void> captureAndUpload() async {
  final helper = InjectionContainer().imageUploadHelper;
  
  final result = await helper.captureAndUploadImage(
    bucketName: SupabaseConstants.restaurantImagesBucket,
    folder: SupabaseConstants.restaurantLogosFolder,
  );
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (imageUrl) => print('Captured and uploaded: $imageUrl'),
  );
}
```

### Example 5: Direct File Upload (Low-Level API)

```dart
import 'dart:io';

Future<void> uploadFile(File file) async {
  final service = InjectionContainer().supabaseService;
  
  final result = await service.uploadImage(
    file: file,
    bucketName: 'restaurant-images',
    folder: 'logos',
    fileName: 'custom_name.jpg', // Optional
  );
  
  result.fold(
    (failure) => print('Error: ${failure.message}'),
    (imageUrl) => print('Uploaded: $imageUrl'),
  );
}
```

### Example 6: Delete an Image

```dart
Future<void> deleteImage(String publicUrl) async {
  final service = InjectionContainer().supabaseService;
  
  // Extract file path from public URL
  final filePath = service.extractFilePathFromUrl(
    publicUrl,
    'restaurant-images',
  );
  
  if (filePath != null) {
    final result = await service.deleteImage(
      bucketName: 'restaurant-images',
      filePath: filePath,
    );
    
    result.fold(
      (failure) => print('Error: ${failure.message}'),
      (_) => print('Image deleted successfully'),
    );
  }
}
```

---

## 🏗️ Integration with Your Restaurant Onboarding Flow

Here's how to integrate image upload in your existing `RestaurantOnboardingCubit`:

```dart
// In lib/features/partner/presentation/cubits/restaurant_onboarding_cubit.dart

import 'package:wassly/core/di/injection_container.dart';
import 'package:wassly/core/utils/image_upload_helper.dart';

class RestaurantOnboardingCubit extends Cubit<RestaurantOnboardingState> {
  final imageHelper = InjectionContainer().imageUploadHelper;
  
  // Upload logo
  Future<void> uploadRestaurantLogo() async {
    emit(state.copyWith(isUploadingLogo: true));
    
    final result = await ImageUploadQuickActions.uploadRestaurantLogo();
    
    result.fold(
      (failure) {
        emit(state.copyWith(
          isUploadingLogo: false,
          errorMessage: failure.message,
        ));
      },
      (logoUrl) {
        emit(state.copyWith(
          isUploadingLogo: false,
          logoUrl: logoUrl,
        ));
      },
    );
  }
  
  // Upload banner
  Future<void> uploadRestaurantBanner() async {
    emit(state.copyWith(isUploadingBanner: true));
    
    final result = await ImageUploadQuickActions.uploadRestaurantBanner();
    
    result.fold(
      (failure) {
        emit(state.copyWith(
          isUploadingBanner: false,
          errorMessage: failure.message,
        ));
      },
      (bannerUrl) {
        emit(state.copyWith(
          isUploadingBanner: false,
          bannerUrl: bannerUrl,
        ));
      },
    );
  }
}
```

### In Your UI (restaurant_onboarding_screen.dart):

```dart
// Add this button in your form
ElevatedButton(
  onPressed: () => context.read<RestaurantOnboardingCubit>().uploadRestaurantLogo(),
  child: Text('Upload Logo'),
),

// Show loading indicator
if (state.isUploadingLogo)
  CircularProgressIndicator(),

// Show uploaded image
if (state.logoUrl != null)
  CachedNetworkImage(imageUrl: state.logoUrl!),
```

---

## 🔧 Configuration Options

### Bucket Names
Configure in `lib/core/constants/supabase_constants.dart`:
- `restaurantImagesBucket` - Restaurant-related images
- `productImagesBucket` - Product photos
- `profileImagesBucket` - User avatars
- `uploadsBucket` - General uploads

### File Upload Settings
```dart
maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB
allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
cacheControl = '3600'; // 1 hour cache
```

### Image Quality Settings
In `ImageUploadHelper`, images are automatically optimized:
- Max width: 1920px
- Max height: 1920px
- Quality: 85%

---

## 🔒 Security Best Practices

### For Development:
- Use public buckets for quick testing
- Enable all operations (SELECT, INSERT, UPDATE, DELETE)

### For Production:
1. **Enable RLS (Row Level Security) on storage buckets**
2. **Create policies based on authentication:**

```sql
-- Example: Users can only upload to their own folder
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Example: Users can read all images
CREATE POLICY "Anyone can view images"
ON storage.objects FOR SELECT
USING (true);
```

3. **Use authenticated uploads:**
```dart
// After user login, Supabase will automatically use the auth token
```

---

## 🧪 Testing

### 1. Test Basic Upload
```bash
flutter run
# Navigate to restaurant onboarding
# Try uploading an image
# Check console for success/error logs
```

### 2. Verify in Supabase Dashboard
1. Go to **Storage** → Select your bucket
2. Check if file appears in the correct folder
3. Copy public URL and test in browser

### 3. Test Error Handling
- Try uploading file > 5MB (should fail)
- Try uploading non-image file (should fail)
- Cancel image picker (should handle gracefully)

---

## 🐛 Troubleshooting

### Error: "Invalid project URL"
- Check `supabase_constants.dart` has correct URL
- Format: `https://xxxxx.supabase.co`

### Error: "Storage bucket not found"
- Create bucket in Supabase Dashboard → Storage
- Match bucket name exactly with constants

### Error: "Permission denied"
- Check bucket policies in Supabase Dashboard
- For testing, enable public access
- For production, configure RLS

### Error: "File size too large"
- Adjust `maxFileSizeInBytes` in `supabase_constants.dart`
- Or compress image before upload

### Images not loading
- Verify public URL is correct
- Check bucket is public or has proper read policy
- Test URL directly in browser

---

## 📚 Additional Resources

- [Supabase Storage Docs](https://supabase.com/docs/guides/storage)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Supabase Storage Policies Guide](https://supabase.com/docs/guides/storage/security/access-control)

---

## 💡 Pro Tips

1. **Save URLs to Firestore:** After uploading to Supabase, save the public URL string to your Firebase Firestore document
2. **Use Cached Network Image:** Display uploaded images with `cached_network_image` package (already in your project)
3. **Handle Loading States:** Always show loading indicators during uploads
4. **Error Messages:** Display user-friendly error messages from failures
5. **Image Compression:** Images are auto-compressed by `image_picker` settings
6. **Unique Filenames:** Service auto-generates unique names using timestamp + random
7. **Delete Old Images:** When updating, delete old image first to save storage

---

## ✅ Next Steps

1. **Add your Supabase credentials** to `supabase_constants.dart`
2. **Create storage buckets** in Supabase Dashboard
3. **Run `flutter pub get`** to install packages
4. **Test the upload** in your app
5. **Integrate with your existing cubits** (examples provided above)

---

**Need help?** Check the code comments in:
- `lib/core/network/supabase_service.dart`
- `lib/core/utils/image_upload_helper.dart`
- `lib/core/constants/supabase_constants.dart`


