# 🎯 Admin App - Complete Guide

## Overview
The **Wassly Admin App** provides comprehensive management capabilities for the entire food delivery platform. Built with Flutter using MVVM architecture and Clean Code principles, it enables administrators to manage restaurants, drivers, users, orders, and analytics.

---

## 🎨 Features Implemented

### ✅ Admin Dashboard
- **Beautiful Grid Layout** with color-coded sections
- **Quick Access Cards** for all management areas:
  - 📝 Restaurants Management
  - 🚗 Drivers Management
  - 👥 Users Management
  - 📊 Analytics & Reports
  - 🛍️ Orders Management
  - ⚙️ Settings
- **Logout Functionality** with secure authentication

### ✅ Restaurant Management
- **List All Restaurants** with real-time updates
- **Beautiful Card UI** showing:
  - Restaurant image
  - Name, description, and address
  - Phone number and email
  - Categories and rating
  - Open/Closed status
- **Toggle Restaurant Status** (Open/Closed)
- **Edit Restaurant** (placeholder for now)
- **Delete Restaurant** with confirmation dialog
- **Create New Restaurant** button with FAB
- **Pull-to-Refresh** support
- **Empty State** with helpful message

### ✅ Create Restaurant Screen
A comprehensive **3-section form** with production-level validation:

#### 1. **Image Upload**
- Tap to select image from gallery
- Image preview with edit/remove options
- Beautiful placeholder UI
- Automatic upload to Firebase Storage

#### 2. **Basic Information**
- Restaurant Name (required)
- Description (required, multi-line)

#### 3. **Contact Information**
- Phone Number (required, validated)
- Email (required, email validation)

#### 4. **Location**
- Address (required, multi-line)
- Location Picker (tap to select on map)
  - Currently sets to Cairo, Egypt (default)
  - Ready for Google Maps integration

#### 5. **Categories**
- Multi-select category picker
- Pre-defined categories:
  - Fast Food, Italian, Chinese, Indian
  - Mexican, Japanese, Thai, Mediterranean
  - American, Vegetarian, Vegan, Desserts
  - Beverages, Healthy, BBQ, Seafood
- Selected categories shown as chips
- Easy remove from chips

#### 6. **Delivery Settings**
- Delivery Fee ($)
- Minimum Order Amount ($)
- Estimated Delivery Time (minutes)

#### 7. **Submit & Validation**
- Complete form validation
- Loading state during creation
- Success/Error messages
- Automatic navigation back to list

---

## 🏗️ Architecture

### **Clean Architecture Layers**

```
lib/features/admin/
├── presentation/
│   ├── views/
│   │   ├── admin_dashboard_screen.dart
│   │   ├── restaurant_management_screen.dart
│   │   └── create_restaurant_screen.dart
│   └── cubits/
│       ├── admin_cubit.dart
│       └── admin_state.dart
```

### **State Management**
- **AdminCubit** - Manages admin operations
  - `createRestaurant()` - Create new restaurant with image upload
  - `updateRestaurantStatus()` - Toggle open/closed status
  - `deleteRestaurant()` - Delete restaurant and associated products

### **States**
- `AdminInitial` - Initial state
- `AdminLoading` - Loading state for operations
- `RestaurantCreatedSuccess` - Restaurant created successfully
- `RestaurantStatusUpdated` - Status toggled successfully
- `RestaurantDeletedSuccess` - Restaurant deleted successfully
- `AdminError` - Error state with message

---

## 📦 Data Models

### **Updated RestaurantEntity**
```dart
class RestaurantEntity {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String? imageUrl;
  final String address;
  final String phone;
  final String? email;
  final List<String> categories;
  final Map<String, dynamic> location;
  final bool isOpen;
  final double rating;
  final int totalReviews;
  final double deliveryFee;
  final double minOrderAmount;
  final int estimatedDeliveryTime;
  final DateTime createdAt;
}
```

### **RestaurantOwnerRepository**
Updated to support admin operations:
- `createRestaurant()` - Admin-style restaurant creation
- `toggleRestaurantStatus()` - Toggle open/closed
- `deleteRestaurant()` - Delete with cascade (products)
- `updateRestaurant()` - Update restaurant details

---

## 🎨 UI/UX Features

### **Color Scheme**
- **Primary Purple** (#9C27B0) - Admin brand color
- **Orange** - Restaurants
- **Blue** - Drivers
- **Green** - Users
- **Red** - Orders
- **Grey** - Settings

### **Interaction Patterns**
- **Pull-to-Refresh** on all lists
- **FAB** for create actions
- **Confirmation Dialogs** for destructive actions
- **Loading States** with spinners
- **Error Handling** with snackbars
- **Success Feedback** with colored snackbars

### **Responsive Design**
- **Grid Layout** for dashboard (2 columns)
- **Card Layout** for lists
- **Scrollable Forms** for create/edit
- **Adaptive Spacing** throughout

---

## 🔥 Firebase Integration

### **Firestore Collections**

#### **restaurants/**
```json
{
  "name": "string",
  "description": "string",
  "imageUrl": "string",
  "address": "string",
  "phone": "string",
  "email": "string",
  "categories": ["string"],
  "location": {
    "latitude": "number",
    "longitude": "number"
  },
  "isOpen": "boolean",
  "rating": "number",
  "totalReviews": "number",
  "deliveryFee": "number",
  "minOrderAmount": "number",
  "estimatedDeliveryTime": "number",
  "createdAt": "timestamp"
}
```

#### **products/** (Related)
- Automatically deleted when restaurant is deleted
- Filtered by `restaurantId`

### **Firebase Storage**
- **restaurants/** - Restaurant images
  - Format: `{timestamp}_{restaurantName}.jpg`
  - Max dimensions: 1920x1080
  - Quality: 85%

---

## 🚀 How to Use

### **Launch Admin App**

#### **VS Code:**
```bash
# Select "Admin - Debug" from launch configurations
# OR
flutter run -t lib/main_admin.dart --flavor admin
```

#### **Terminal:**
```bash
flutter run -t lib/main_admin.dart --flavor admin
```

### **Admin Dashboard Navigation**
1. Launch Admin app
2. Login with admin credentials
3. Select management area from grid

### **Create Restaurant**
1. Go to **Restaurants** from dashboard
2. Tap **Create Restaurant** button
3. Upload restaurant image
4. Fill in all required fields
5. Select categories
6. Set location
7. Configure delivery settings
8. Tap **Create Restaurant**

### **Manage Restaurants**
- **Toggle Status**: Use switch on each card
- **Edit**: Tap edit icon (placeholder)
- **Delete**: Tap delete icon → confirm

---

## 🧪 Testing

### **Test Scenarios**

#### **Create Restaurant**
✅ Valid form submission
✅ Image upload and preview
✅ Category selection
✅ Form validation (all fields)
✅ Success feedback
✅ Error handling

#### **Restaurant Management**
✅ List all restaurants
✅ Toggle status
✅ Delete restaurant
✅ Pull-to-refresh
✅ Empty state

---

## 📋 Routes

```dart
/admin                      → Admin Dashboard
/admin/restaurants          → Restaurant List
/admin/restaurants/create   → Create Restaurant
/admin/restaurants/edit/:id → Edit Restaurant (placeholder)
/admin/drivers              → Driver Management (placeholder)
/admin/users                → User Management (placeholder)
/admin/orders               → Order Management (placeholder)
/admin/analytics            → Analytics (placeholder)
/admin/settings             → Settings (placeholder)
```

---

## 🔐 Security

### **Firestore Rules** (Recommended)
```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    // Admins can manage restaurants
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      request.auth.token.role == 'admin';
    }
    
    // Admins can manage products
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      request.auth.token.role == 'admin';
    }
  }
}
```

### **Storage Rules** (Recommended)
```javascript
service firebase.storage {
  match /b/{bucket}/o {
    match /restaurants/{imageId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      request.auth.token.role == 'admin';
    }
  }
}
```

---

## 🎯 Future Enhancements

### **Coming Soon**
- [ ] **Edit Restaurant** - Full edit functionality
- [ ] **Driver Management** - CRUD for drivers
- [ ] **User Management** - User list and moderation
- [ ] **Order Management** - View and manage all orders
- [ ] **Analytics Dashboard** - Charts and insights
- [ ] **Settings** - App configuration
- [ ] **Search & Filters** - Find restaurants quickly
- [ ] **Bulk Operations** - Multi-select actions
- [ ] **Export Data** - CSV/PDF reports
- [ ] **Audit Logs** - Track admin actions

---

## 🐛 Known Issues

### **Location Picker**
- Currently hardcoded to Cairo, Egypt
- **Solution**: Integrate Google Maps Place Picker

### **Edit Restaurant**
- Placeholder screen implemented
- **Solution**: Clone create screen, pre-fill data

---

## 💡 Tips & Best Practices

### **Creating Restaurants**
1. **Use High-Quality Images** - Minimum 1200x800px
2. **Write Clear Descriptions** - Help customers decide
3. **Select Accurate Categories** - Improves discoverability
4. **Set Realistic Delivery Times** - Builds trust
5. **Verify Phone/Email** - Enable customer contact

### **Managing Status**
- **Open**: Restaurant accepting orders
- **Closed**: Restaurant not accepting orders (still visible)
- **Delete**: Complete removal (use cautiously)

---

## 📞 Support

For issues or questions:
- Check Firebase logs
- Review Firestore rules
- Verify admin permissions
- Check network connectivity

---

## 🎉 Summary

The **Admin App** is now fully functional with:
✅ Beautiful, intuitive UI
✅ Complete restaurant management
✅ Production-level form validation
✅ Real-time updates
✅ Error handling and feedback
✅ Image upload to Firebase
✅ Clean architecture
✅ MVVM pattern
✅ Scalable codebase

**Next Steps**: Launch the app, create restaurants, and manage your food delivery platform! 🚀

