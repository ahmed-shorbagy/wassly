# ✅ YOUR TODO LIST: Supabase Setup

## 🎯 What You Need to Do

I've completed all the coding. You just need to **configure Supabase** (takes ~15 minutes).

---

## ☑️ TODO #1: Add Your Supabase Credentials

**File:** `lib/core/constants/supabase_constants.dart`

**Find these lines (9-13):**
```dart
static const String projectUrl = 'YOUR_SUPABASE_PROJECT_URL';
static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
```

**Replace with your actual values from Supabase Dashboard:**

1. Go to [supabase.com](https://supabase.com) → Your Project
2. Click **Settings** (gear icon) → **API**
3. Copy **URL** and paste it as `projectUrl`
4. Copy **anon / public** key and paste it as `anonKey`

**Example:**
```dart
static const String projectUrl = 'https://abc123xyz.supabase.co';
static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## ☑️ TODO #2: Create Storage Buckets

**In Supabase Dashboard → Storage:**

Click **"New bucket"** and create these 3 buckets:

### Bucket 1:
- **Name:** `restaurant-images`
- **Public bucket:** ✅ Checked
- Click **Create**

### Bucket 2:
- **Name:** `product-images`
- **Public bucket:** ✅ Checked
- Click **Create**

### Bucket 3:
- **Name:** `profile-images`
- **Public bucket:** ✅ Checked
- Click **Create**

**IMPORTANT:** Names must match exactly (with dashes, not underscores)

---

## ☑️ TODO #3: Configure Bucket Policies

For **each of the 3 buckets** above:

1. Click on bucket name (e.g., `restaurant-images`)
2. Click **Policies** tab
3. Click **"New Policy"**
4. Choose **"Get started quickly"**
5. Select **"Enable all operations"** template
6. Click **"Use this template"**
7. Click **"Save policy"**

**Repeat for all 3 buckets!**

> This allows public read/write access (good for testing). For production, we'll add authentication later.

---

## ☑️ TODO #4: Test It!

```bash
flutter run -t lib/main_admin.dart
```

1. Open the admin app
2. Go to **Create Restaurant**
3. Upload an image
4. Create a restaurant
5. Check if it works! ✨

**Expected Console Output:**
```
✅ Supabase initialized
✅ Uploading restaurant image to Supabase...
✅ Image uploaded successfully
✅ Restaurant created with ID: xxxxx
```

**Verify in Supabase Dashboard:**
- Go to **Storage** → `restaurant-images` → `logos`
- Your uploaded image should be there!

---

## 📚 Documentation Files

I created these guides for you:

1. **`QUICK_START_ADMIN_UPLOADS.md`** ← Start here (simple, 15 min)
2. **`ADMIN_IMAGE_UPLOAD_GUIDE.md`** ← Detailed guide (troubleshooting, examples)
3. **`SUPABASE_SETUP_GUIDE.md`** ← Complete Supabase integration guide
4. **`SUPABASE_TODO.md`** ← This file (your checklist)

---

## ✅ What's Already Done (By Me)

- ✅ Added `supabase_flutter` package
- ✅ Created Supabase service layer
- ✅ Created image upload helpers
- ✅ Updated repositories to use Supabase
- ✅ Initialized Supabase in all apps
- ✅ Configured dependency injection
- ✅ Integrated with admin UI
- ✅ Added proper error handling
- ✅ Followed your clean architecture
- ✅ Used MVVM pattern
- ✅ All code commented and logged

**Nothing to code - just configure!**

---

## 🎯 Quick Verification

After completing TODOs 1-3, run this checklist:

```bash
# 1. Check no compile errors
flutter analyze

# 2. Run the app
flutter run -t lib/main_admin.dart
```

**In the app:**
- [ ] App launches without errors
- [ ] Can navigate to Create Restaurant
- [ ] Can pick an image
- [ ] Can see image preview
- [ ] Can create restaurant
- [ ] See success message
- [ ] Restaurant appears in list

**In Supabase Dashboard:**
- [ ] Image appears in Storage bucket
- [ ] Can click image and view it
- [ ] Can copy public URL

**In Firebase Firestore:**
- [ ] Restaurant document created
- [ ] Document has `imageUrl` field
- [ ] URL starts with your Supabase project URL

---

## 🚨 If Something Doesn't Work

### Console shows "Invalid project URL"
→ Check TODO #1 - credentials might be wrong

### Console shows "Bucket not found"
→ Check TODO #2 - bucket names must match exactly

### Console shows "Permission denied" or "403"
→ Check TODO #3 - you might have missed setting policies for a bucket

### Other issues?
→ Check `ADMIN_IMAGE_UPLOAD_GUIDE.md` troubleshooting section

---

## 📞 Summary

**Your work:** 3 configuration steps in Supabase Dashboard (~15 minutes)

**My work:** Complete Supabase integration with your app (✅ Done)

**Result:** Admin can upload restaurant photos via Supabase Storage! 🎉

---

## 🔥 Let's Go!

Start with TODO #1 and work your way down. You'll be uploading images in 15 minutes!

```bash
# When ready, run:
flutter pub get
flutter run -t lib/main_admin.dart
```

Good luck! 🚀

