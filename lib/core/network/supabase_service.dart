import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import '../utils/logger.dart';
import '../errors/failures.dart';
import 'package:dartz/dartz.dart';

/// Supabase Storage Service
/// 
/// Provides methods for interacting with Supabase Storage.
/// This service handles file uploads, downloads, and deletions.
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Get the Supabase client instance
  SupabaseClient get client => _client;

  /// Upload an image file to Supabase Storage
  /// 
  /// Parameters:
  /// - [file]: The image file to upload
  /// - [bucketName]: The storage bucket name
  /// - [folder]: Optional folder path within the bucket
  /// - [fileName]: Optional custom file name (auto-generated if not provided)
  /// 
  /// Returns:
  /// - Right(String): The public URL of the uploaded file
  /// - Left(Failure): An error if the upload fails
  Future<Either<Failure, String>> uploadImage({
    required File file,
    required String bucketName,
    String? folder,
    String? fileName,
  }) async {
    try {
      AppLogger.logInfo('Uploading image to bucket: $bucketName');

      // Validate file size
      final fileSize = await file.length();
      if (fileSize > SupabaseConstants.maxFileSizeInBytes) {
        AppLogger.logWarning('File size exceeds limit: $fileSize bytes');
        return Left(
          ServerFailure(
            'File size exceeds ${SupabaseConstants.maxFileSizeInBytes ~/ (1024 * 1024)}MB limit',
          ),
        );
      }

      // Validate file extension
      final extension = file.path.split('.').last.toLowerCase();
      if (!SupabaseConstants.allowedImageExtensions.contains(extension)) {
        AppLogger.logWarning('Invalid file extension: $extension');
        return Left(
          ServerFailure('Invalid file type. Allowed: ${SupabaseConstants.allowedImageExtensions.join(", ")}'),
        );
      }

      // Generate file name if not provided
      final uniqueFileName = fileName ?? _generateFileName(extension);
      
      // Construct full path
      final path = folder != null ? '$folder/$uniqueFileName' : uniqueFileName;

      AppLogger.logInfo('Uploading to path: $path');

      // Upload the file
      await _client.storage.from(bucketName).upload(
            path,
            file,
            fileOptions: FileOptions(
              cacheControl: SupabaseConstants.cacheControl,
              upsert: false, // Don't overwrite existing files
            ),
          );

      // Get the public URL
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(path);

      AppLogger.logSuccess('Image uploaded successfully: $publicUrl');
      return Right(publicUrl);
    } on StorageException catch (e) {
      AppLogger.logError('Storage error uploading image', error: e);
      return Left(ServerFailure('Failed to upload image: ${e.message}'));
    } catch (e, stackTrace) {
      AppLogger.logError('Unexpected error uploading image', error: e, stackTrace: stackTrace);
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }

  /// Upload multiple images to Supabase Storage
  /// 
  /// Parameters:
  /// - [files]: List of image files to upload
  /// - [bucketName]: The storage bucket name
  /// - [folder]: Optional folder path within the bucket
  /// 
  /// Returns:
  /// - Right(List<String>): List of public URLs of uploaded files
  /// - Left(Failure): An error if any upload fails
  Future<Either<Failure, List<String>>> uploadMultipleImages({
    required List<File> files,
    required String bucketName,
    String? folder,
  }) async {
    try {
      AppLogger.logInfo('Uploading ${files.length} images to bucket: $bucketName');
      
      final List<String> uploadedUrls = [];

      for (final file in files) {
        final result = await uploadImage(
          file: file,
          bucketName: bucketName,
          folder: folder,
        );

        result.fold(
          (failure) => throw Exception(failure.message),
          (url) => uploadedUrls.add(url),
        );
      }

      AppLogger.logSuccess('All ${files.length} images uploaded successfully');
      return Right(uploadedUrls);
    } catch (e, stackTrace) {
      AppLogger.logError('Error uploading multiple images', error: e, stackTrace: stackTrace);
      return Left(ServerFailure('Failed to upload images: $e'));
    }
  }

  /// Delete an image from Supabase Storage
  /// 
  /// Parameters:
  /// - [bucketName]: The storage bucket name
  /// - [filePath]: The full path of the file to delete
  /// 
  /// Returns:
  /// - Right(void): Success
  /// - Left(Failure): An error if the deletion fails
  Future<Either<Failure, void>> deleteImage({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      AppLogger.logInfo('Deleting image: $filePath from bucket: $bucketName');

      await _client.storage.from(bucketName).remove([filePath]);

      AppLogger.logSuccess('Image deleted successfully');
      return const Right(null);
    } on StorageException catch (e) {
      AppLogger.logError('Storage error deleting image', error: e);
      return Left(ServerFailure('Failed to delete image: ${e.message}'));
    } catch (e, stackTrace) {
      AppLogger.logError('Unexpected error deleting image', error: e, stackTrace: stackTrace);
      return Left(ServerFailure('Failed to delete image: $e'));
    }
  }

  /// Extract file path from a Supabase public URL
  /// 
  /// This is useful when you need to delete a file using its public URL
  String? extractFilePathFromUrl(String publicUrl, String bucketName) {
    try {
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      
      // Find the bucket name in the path
      final bucketIndex = segments.indexOf(bucketName);
      if (bucketIndex == -1) return null;
      
      // The file path is everything after the bucket name
      final filePath = segments.sublist(bucketIndex + 1).join('/');
      return filePath;
    } catch (e) {
      AppLogger.logError('Error extracting file path from URL', error: e);
      return null;
    }
  }

  /// Generate a unique file name
  String _generateFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return '${timestamp}_$random.$extension';
  }

  /// Check if a file exists in storage
  Future<bool> fileExists({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await _client.storage.from(bucketName).list(path: filePath);
      return true;
    } catch (e) {
      return false;
    }
  }
}


