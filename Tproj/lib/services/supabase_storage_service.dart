// File: lib/services/supabase_storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Initialize Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  // Upload a file to Supabase Storage
  Future<String?> uploadFile({
    required String bucketName,
    required String path,
    required File file,
  }) async {
    try {
      final fileExtension = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = path.isEmpty ? fileName : '$path/$fileName';
      
      await _supabase
          .storage
          .from(bucketName)
          .upload(filePath, file);
      
      // Get the public URL
      final fileUrl = _supabase
          .storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      return fileUrl;
    } catch (e) {
      print('Error uploading file to Supabase Storage: $e');
      return null;
    }
  }
  
  // Upload multiple files to Supabase Storage
  Future<List<String>> uploadFiles({
    required String bucketName,
    required String path,
    required List<File> files,
  }) async {
    List<String> fileUrls = [];
    
    try {
      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final fileExtension = file.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.$fileExtension';
        final filePath = path.isEmpty ? fileName : '$path/$fileName';
        
        await _supabase
            .storage
            .from(bucketName)
            .upload(filePath, file);
        
        // Get the public URL
        final fileUrl = _supabase
            .storage
            .from(bucketName)
            .getPublicUrl(filePath);
        
        fileUrls.add(fileUrl);
      }
      
      return fileUrls;
    } catch (e) {
      print('Error uploading files to Supabase Storage: $e');
      return fileUrls;
    }
  }
  
  // Download a file from Supabase Storage
  Future<File?> downloadFile({
    required String bucketName,
    required String path,
    required String savePath,
  }) async {
    try {
      final bytes = await _supabase
          .storage
          .from(bucketName)
          .download(path);
      
      final file = File(savePath);
      await file.writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      print('Error downloading file from Supabase Storage: $e');
      return null;
    }
  }
  
  // Get a public URL for a file
  String getPublicUrl({
    required String bucketName,
    required String path,
  }) {
    return _supabase
        .storage
        .from(bucketName)
        .getPublicUrl(path);
  }
  
  // Delete a file from Supabase Storage
  Future<bool> deleteFile({
    required String bucketName,
    required String path,
  }) async {
    try {
      await _supabase
          .storage
          .from(bucketName)
          .remove([path]);
      
      return true;
    } catch (e) {
      print('Error deleting file from Supabase Storage: $e');
      return false;
    }
  }
  
  // Delete multiple files from Supabase Storage
  Future<bool> deleteFiles({
    required String bucketName,
    required List<String> paths,
  }) async {
    try {
      await _supabase
          .storage
          .from(bucketName)
          .remove(paths);
      
      return true;
    } catch (e) {
      print('Error deleting files from Supabase Storage: $e');
      return false;
    }
  }
}
