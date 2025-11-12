# Admin Restaurant Image Upload Guide

## 🎯 Overview
Your admin panel is now configured to use **Supabase Storage** for uploading restaurant images. The integration is complete and follows your clean architecture principles.

---

## ✅ What's Already Done

### 1. **Repository Updated**
- ✅ `RestaurantOwnerRepositoryImpl` now uses Supabase instead of Firebase Storage
- ✅ New method `uploadImageFile()` for direct file uploads to Supabase
- ✅ Automatic integration with Supabase service layer

### 2. **Admin UI Ready**
- ✅ `CreateRestaurantScreen` has image picker functionality
- ✅ Image preview and validation built-in
- ✅ All form fields are ready

### 3. **Clean Architecture**
- ✅ Follows MVVM pattern
- ✅ Separation of concerns maintained
- ✅ Dependency injection properly configured

---

## 🚀 What You Need to Do

### Step 1: Configure Supabase Credentials (REQUIRED)

Open `lib/core/constants/supabase_constants.dart` and update:

```dart
/// Supabase Project URL
static const String projectUrl = 'https://YOUR_PROJECT.supabase.co';

/// Supabase Anonymous Key
static const String anonKey = 'YOUR_ANON_KEY_HERE';
```

**Where to find these:**
1. Go to [supabase.com](https://supabase.com) and open your project
2. Click: **Project Settings** → **API**
3. Copy:
   - **URL** field → use as `projectUrl`
   - **anon public** key → use as `anonKey`

---

### Step 2: Create Storage Buckets in Supabase

In your Supabase Dashboard:

1. Go to **Storage** (left sidebar)
2. Click **"New bucket"**
3. Create these buckets:

#### Bucket 1: `restaurant-images`
- **Name:** `restaurant-images`
- **Public bucket:** ✅ Yes (check this box)
- Click **Create bucket**

#### Bucket 2: `product-images`
- **Name:** `product-images`
- **Public bucket:** ✅ Yes
- Click **Create bucket**

#### Bucket 3: `profile-images`
- **Name:** `profile-images`
- **Public bucket:** ✅ Yes
- Click **Create bucket**

---

### Step 3: Set Up Bucket Policies (IMPORTANT)

For each bucket you created, you need to set access policies:

#### Option A: Public Access (Quick Setup for Testing)

1. In Supabase Dashboard, go to **Storage**
2. Click on `restaurant-images` bucket
3. Go to **Policies** tab
4. Click **"New Policy"**
5. Choose **"For full customization"**
6. Create **4 policies** (one for each operation):

**Policy 1: SELECT (Read)**
```sql
Policy name: Public Read Access
Allowed operation: SELECT
Policy definition: true
```

**Policy 2: INSERT (Upload)**
```sql
Policy name: Public Upload Access
Allowed operation: INSERT
Policy definition: true
```

**Policy 3: UPDATE**
```sql
Policy name: Public Update Access
Allowed operation: UPDATE
Policy definition: true
```

**Policy 4: DELETE**
```sql
Policy name: Public Delete Access
Allowed operation: DELETE
Policy definition: true
```

6. Click **Review** → **Save policy**
7. **Repeat for other buckets** (`product-images`, `profile-images`)

#### Option B: Authenticated Access Only (Recommended for Production)

For production, you should restrict uploads to authenticated users only. We can configure this later after testing.

---

### Step 4: Test the Integration

1. **Run your admin app:**
```bash
flutter run -t lib/main_admin.dart
```

2. **Navigate to Create Restaurant:**
   - Open the admin dashboard
   - Click "Create Restaurant" or navigate to the create screen

3. **Upload an image:**
   - Tap on "Tap to upload restaurant image"
   - Select an image from gallery
   - Fill in restaurant details
   - Click "Create Restaurant"

4. **Check the console logs:**
You should see:
```
✅ Supabase initialized
✅ Uploading restaurant image to Supabase...
✅ Image uploaded successfully
✅ Restaurant created with ID: xxxxx
```

5. **Verify in Supabase:**
   - Go to Supabase Dashboard → **Storage** → `restaurant-images` → `logos`
   - You should see your uploaded image
   - Click on it to get the public URL

---

## 📋 How It Works Now

### Current Flow:

1. **Admin picks an image** using the image picker in `CreateRestaurantScreen`
2. **Form validation** ensures all required fields are filled
3. **Image upload to Supabase:**
   - AdminCubit calls `repository.createRestaurant()`
   - Repository uploads image to Supabase Storage
   - Gets back a public URL
4. **Save to Firestore:**
   - Restaurant data (including image URL) saved to Firestore
   - Firebase handles the database
   - Supabase handles the files

### Data Storage:
- **Images/Files:** Supabase Storage
- **Restaurant Data:** Firebase Firestore
- **Authentication:** Firebase Auth

---

## 🎨 UI Features Available

Your `CreateRestaurantScreen` already has:

✅ **Image Upload Section**
- Tap to select image
- Image preview
- Change image option
- Remove image option

✅ **Form Fields**
- Restaurant name
- Description
- Contact info (phone, email)
- Address
- Location picker
- Category selector
- Delivery settings

✅ **Validation**
- Email validation
- Phone validation
- Required fields check
- Image requirement check

✅ **Loading States**
- Loading indicator during creation
- Success/error messages
- Navigation after success

---

## 🔧 Customization Options

### Change Image Quality Settings

In `lib/features/admin/presentation/views/create_restaurant_screen.dart` line 68-73:

```dart
final XFile? image = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 1920,    // Change this
  maxHeight: 1080,   // Change this
  imageQuality: 85,  // Change this (0-100)
);
```

### Change Upload Bucket/Folder

In `lib/features/restaurants/data/repositories/restaurant_owner_repository_impl.dart` line 126-130:

```dart
final imageUploadResult = await uploadImageFile(
  imageFile,
  SupabaseConstants.restaurantImagesBucket,  // Change bucket here
  SupabaseConstants.restaurantLogosFolder,   // Change folder here
);
```

### Add More Image Fields (Logo + Banner)

If you want to upload multiple images (logo AND banner), you can modify the `createRestaurant` method in the repository to accept multiple files.

**Example modification:**

```dart
// In AdminCubit
Future<void> createRestaurant({
  required File logoFile,      // Add this
  required File bannerFile,    // Add this
  // ... other parameters
}) async {
  // Upload both images
  // Save both URLs
}
```

---

## 📱 Testing Checklist

- [ ] Supabase credentials added to `supabase_constants.dart`
- [ ] Storage buckets created in Supabase Dashboard
- [ ] Bucket policies configured
- [ ] App runs without errors
- [ ] Can pick image from gallery
- [ ] Can see image preview
- [ ] Can create restaurant successfully
- [ ] Image appears in Supabase Storage
- [ ] Restaurant appears in Firebase Firestore with image URL
- [ ] Can view restaurant with image in the app

---

## 🐛 Troubleshooting

### Error: "Invalid project URL"
**Solution:** Update `supabase_constants.dart` with correct URL from Supabase Dashboard

### Error: "Storage bucket not found"
**Solution:** Create the bucket `restaurant-images` in Supabase Dashboard → Storage

### Error: "Permission denied" or "403 Forbidden"
**Solution:** 
1. Go to Supabase Dashboard → Storage → `restaurant-images`
2. Click **Policies** tab
3. Add policies as described in Step 3 above

### Error: "File size too large"
**Solution:** 
- Current limit: 5MB (set in `supabase_constants.dart`)
- Increase it or compress images before upload

### Image uploads but doesn't show in app
**Solution:**
1. Check if bucket is public
2. Verify the URL in Firestore document
3. Test URL directly in browser
4. Check if `cached_network_image` package is configured correctly

### App crashes on image upload
**Solution:**
1. Check console for error messages
2. Verify Supabase credentials are correct
3. Ensure buckets exist
4. Check internet connection

---

## 🎯 Quick Start Commands

```bash
# 1. Install dependencies (if not done)
flutter pub get

# 2. Run admin app
flutter run -t lib/main_admin.dart

# 3. Build admin app for release
flutter build apk -t lib/main_admin.dart --release

# 4. Check for linter errors
flutter analyze
```

---

## 📖 Code Examples

### Example 1: Simple Restaurant Creation (Current Implementation)

```dart
// In your admin UI
ElevatedButton(
  onPressed: () {
    context.read<AdminCubit>().createRestaurant(
      name: 'Pizza Palace',
      description: 'Best pizza in town',
      address: '123 Main St',
      phone: '+1234567890',
      email: 'info@pizzapalace.com',
      categories: ['Italian', 'Fast Food'],
      location: LatLng(30.0444, 31.2357),
      imageFile: selectedImage!, // Your picked File object
      deliveryFee: 5.0,
      minOrderAmount: 10.0,
      estimatedDeliveryTime: 30,
    );
  },
  child: Text('Create Restaurant'),
)
```

### Example 2: Upload Image Separately (Advanced)

```dart
// If you want to upload an image separately first
final helper = InjectionContainer().imageUploadHelper;

final result = await helper.pickAndUploadImage(
  bucketName: SupabaseConstants.restaurantImagesBucket,
  folder: SupabaseConstants.restaurantLogosFolder,
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (imageUrl) {
    // Use this URL when creating restaurant
    print('Image uploaded: $imageUrl');
  },
);
```

### Example 3: Programmatic Image Upload (No UI Picker)

```dart
import 'dart:io';

// If you already have a File object
final file = File('/path/to/image.jpg');

final service = InjectionContainer().supabaseService;
final result = await service.uploadImage(
  file: file,
  bucketName: 'restaurant-images',
  folder: 'logos',
);

result.fold(
  (failure) => print('Upload failed: ${failure.message}'),
  (url) => print('Uploaded to: $url'),
);
```

---

## 🔐 Security Notes

### Current Setup (Development)
- Public buckets allow anyone to upload/read
- Good for testing and development
- **Not recommended for production**

### Production Recommendations
1. **Enable Row Level Security (RLS)** on storage buckets
2. **Restrict uploads** to authenticated admin users only
3. **Add file validation** on the server side
4. **Implement file scanning** for malicious content
5. **Set up CDN** for better performance
6. **Monitor storage usage** and set quotas

---

## 📚 Additional Resources

- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Storage Policies Guide](https://supabase.com/docs/guides/storage/security/access-control)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Image Picker Package](https://pub.dev/packages/image_picker)

---

## ✅ Next Steps

1. **Configure Supabase credentials** (Step 1)
2. **Create storage buckets** (Step 2)
3. **Set up policies** (Step 3)
4. **Test restaurant creation** (Step 4)
5. **Optional: Add banner image upload**
6. **Optional: Add product image upload for products**
7. **Optional: Configure production security**

---

## 💡 Pro Tips

1. **Test with small images first** (< 1MB) to ensure everything works
2. **Check Supabase Dashboard** → **Storage** to see uploaded files
3. **Copy public URLs** from Supabase to verify they work in browser
4. **Use the logger** - All operations log to console with clear messages
5. **Start with public buckets** for testing, secure them later
6. **Monitor storage usage** in Supabase Dashboard (free tier has limits)

---

## 🎉 You're All Set!

Once you complete Steps 1-3, your admin panel will be able to:
- ✅ Upload restaurant images to Supabase
- ✅ Create restaurants with images
- ✅ Store image URLs in Firestore
- ✅ Display images in the app

The code is already written and integrated. You just need to configure Supabase!

---

**Questions?** Check the troubleshooting section or review the code in:
- `lib/core/network/supabase_service.dart`
- `lib/features/restaurants/data/repositories/restaurant_owner_repository_impl.dart`
- `lib/features/admin/presentation/views/create_restaurant_screen.dart`

