/// Supabase Configuration Constants
/// 
/// This file contains all Supabase-related configuration.
/// Update the values below with your Supabase project credentials.
class SupabaseConstants {
  // ⚠️ IMPORTANT: Replace these values with your actual Supabase project credentials
  // You can find these in your Supabase project settings: 
  // Dashboard > Project Settings > API
  
  /// Supabase Project URL
  /// Example: 'https://xyzcompany.supabase.co'
  static const String projectUrl = 'https://mlgtpvyaazvykdgwdypt.supabase.co';
  
  /// Supabase Anonymous Key (Public Key)
  /// This is safe to use in client-side code
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sZ3RwdnlhYXp2eWtkZ3dkeXB0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5NDUyNDQsImV4cCI6MjA3ODUyMTI0NH0.WiVBqveap7o1BD3eQqv4diCMlwD80jrieg7NA7d8d2A';
  
  // Storage Bucket Names
  /// Bucket for restaurant images (logos, banners, etc.)
  static const String restaurantImagesBucket = 'restaurant-images';
  
  /// Bucket for product images
  static const String productImagesBucket = 'product-images';
  
  /// Bucket for user profile images
  static const String profileImagesBucket = 'profile-images';
  
  /// Bucket for driver images (personal photos, licenses, vehicle photos)
  static const String driverImagesBucket = 'driver-images';
  
  /// General uploads bucket
  static const String uploadsBucket = 'uploads';
  
  // Storage Folders (within buckets)
  static const String restaurantLogosFolder = 'logos';
  static const String restaurantBannersFolder = 'banners';
  static const String productPhotosFolder = 'photos';
  static const String profileAvatarsFolder = 'avatars';
  
  // File Upload Settings
  static const int maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  
  /// Cache control header for uploaded files (in seconds)
  /// 3600 = 1 hour
  static const String cacheControl = '3600';
}


