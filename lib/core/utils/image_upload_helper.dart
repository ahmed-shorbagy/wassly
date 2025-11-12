import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../constants/supabase_constants.dart';
import '../network/supabase_service.dart';
import 'logger.dart';

/// Image Upload Helper
/// 
/// Provides convenient methods for picking and uploading images.
/// This is a utility class that combines image picker with Supabase storage.
class ImageUploadHelper {
  final ImagePicker _picker;
  final SupabaseService _supabaseService;

  ImageUploadHelper({
    ImagePicker? picker,
    SupabaseService? supabaseService,
  })  : _picker = picker ?? ImagePicker(),
        _supabaseService = supabaseService ?? SupabaseService();

  /// Pick an image from gallery and upload it
  /// 
  /// Parameters:
  /// - [bucketName]: The Supabase storage bucket name
  /// - [folder]: Optional folder path within the bucket
  /// 
  /// Returns:
  /// - Right(String): The public URL of the uploaded image
  /// - Left(Failure): An error if picking or uploading fails
  Future<Either<Failure, String>> pickAndUploadImage({
    required String bucketName,
    String? folder,
  }) async {
    try {
      AppLogger.logInfo('Picking image from gallery');

      // Pick image from gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        AppLogger.logWarning('No image selected');
        return Left(CacheFailure('No image selected'));
      }

      // Convert XFile to File
      final file = File(pickedFile.path);

      // Upload the image
      AppLogger.logInfo('Uploading selected image');
      return await _supabaseService.uploadImage(
        file: file,
        bucketName: bucketName,
        folder: folder,
      );
    } catch (e, stackTrace) {
      AppLogger.logError('Error picking and uploading image', error: e, stackTrace: stackTrace);
      return Left(CacheFailure('Failed to pick and upload image: $e'));
    }
  }

  /// Pick an image from camera and upload it
  /// 
  /// Parameters:
  /// - [bucketName]: The Supabase storage bucket name
  /// - [folder]: Optional folder path within the bucket
  /// 
  /// Returns:
  /// - Right(String): The public URL of the uploaded image
  /// - Left(Failure): An error if capturing or uploading fails
  Future<Either<Failure, String>> captureAndUploadImage({
    required String bucketName,
    String? folder,
  }) async {
    try {
      AppLogger.logInfo('Capturing image from camera');

      // Capture image from camera
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        AppLogger.logWarning('No image captured');
        return Left(CacheFailure('No image captured'));
      }

      // Convert XFile to File
      final file = File(pickedFile.path);

      // Upload the image
      AppLogger.logInfo('Uploading captured image');
      return await _supabaseService.uploadImage(
        file: file,
        bucketName: bucketName,
        folder: folder,
      );
    } catch (e, stackTrace) {
      AppLogger.logError('Error capturing and uploading image', error: e, stackTrace: stackTrace);
      return Left(CacheFailure('Failed to capture and upload image: $e'));
    }
  }

  /// Pick multiple images from gallery and upload them
  /// 
  /// Parameters:
  /// - [bucketName]: The Supabase storage bucket name
  /// - [folder]: Optional folder path within the bucket
  /// - [maxImages]: Maximum number of images to pick (default: 5)
  /// 
  /// Returns:
  /// - Right(List<String>): List of public URLs of uploaded images
  /// - Left(Failure): An error if picking or uploading fails
  Future<Either<Failure, List<String>>> pickAndUploadMultipleImages({
    required String bucketName,
    String? folder,
    int maxImages = 5,
  }) async {
    try {
      AppLogger.logInfo('Picking multiple images from gallery');

      // Pick multiple images from gallery
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFiles.isEmpty) {
        AppLogger.logWarning('No images selected');
        return Left(CacheFailure('No images selected'));
      }

      // Limit the number of images
      final filesToUpload = pickedFiles.take(maxImages).toList();

      if (filesToUpload.length < pickedFiles.length) {
        AppLogger.logWarning('Only uploading first $maxImages of ${pickedFiles.length} selected images');
      }

      // Convert XFiles to Files
      final files = filesToUpload.map((xFile) => File(xFile.path)).toList();

      // Upload all images
      AppLogger.logInfo('Uploading ${files.length} images');
      return await _supabaseService.uploadMultipleImages(
        files: files,
        bucketName: bucketName,
        folder: folder,
      );
    } catch (e, stackTrace) {
      AppLogger.logError('Error picking and uploading multiple images', error: e, stackTrace: stackTrace);
      return Left(CacheFailure('Failed to pick and upload images: $e'));
    }
  }

  /// Show a bottom sheet to choose between camera and gallery
  /// 
  /// This is a utility method that can be used in your UI layer
  /// to show image source options. You'll need to implement the UI part
  /// in your presentation layer.
  Future<Either<Failure, String>> showImageSourceOptionsAndUpload({
    required String bucketName,
    String? folder,
    required ImageSource source,
  }) async {
    if (source == ImageSource.camera) {
      return captureAndUploadImage(bucketName: bucketName, folder: folder);
    } else {
      return pickAndUploadImage(bucketName: bucketName, folder: folder);
    }
  }

  /// Upload a file directly (when you already have a File object)
  /// 
  /// Parameters:
  /// - [file]: The file to upload
  /// - [bucketName]: The Supabase storage bucket name
  /// - [folder]: Optional folder path within the bucket
  /// 
  /// Returns:
  /// - Right(String): The public URL of the uploaded file
  /// - Left(Failure): An error if uploading fails
  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String bucketName,
    String? folder,
  }) async {
    return await _supabaseService.uploadImage(
      file: file,
      bucketName: bucketName,
      folder: folder,
    );
  }
}

/// Quick access functions for common upload scenarios
class ImageUploadQuickActions {
  static final _helper = ImageUploadHelper();

  /// Upload restaurant logo
  static Future<Either<Failure, String>> uploadRestaurantLogo() async {
    return _helper.pickAndUploadImage(
      bucketName: SupabaseConstants.restaurantImagesBucket,
      folder: SupabaseConstants.restaurantLogosFolder,
    );
  }

  /// Upload restaurant banner
  static Future<Either<Failure, String>> uploadRestaurantBanner() async {
    return _helper.pickAndUploadImage(
      bucketName: SupabaseConstants.restaurantImagesBucket,
      folder: SupabaseConstants.restaurantBannersFolder,
    );
  }

  /// Upload product image
  static Future<Either<Failure, String>> uploadProductImage() async {
    return _helper.pickAndUploadImage(
      bucketName: SupabaseConstants.productImagesBucket,
      folder: SupabaseConstants.productPhotosFolder,
    );
  }

  /// Upload multiple product images
  static Future<Either<Failure, List<String>>> uploadProductImages({
    int maxImages = 5,
  }) async {
    return _helper.pickAndUploadMultipleImages(
      bucketName: SupabaseConstants.productImagesBucket,
      folder: SupabaseConstants.productPhotosFolder,
      maxImages: maxImages,
    );
  }

  /// Upload profile picture
  static Future<Either<Failure, String>> uploadProfilePicture() async {
    return _helper.pickAndUploadImage(
      bucketName: SupabaseConstants.profileImagesBucket,
      folder: SupabaseConstants.profileAvatarsFolder,
    );
  }
}


