// File: lib/services/supabase_storage_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

// On mobile: dart:io File; on web: storage_client stub File
import 'dart:io' if (dart.library.html) 'package:storage_client/src/file_stub.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Call once in main()
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) => Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  /// Upload a single file.
  Future<String?> uploadFile({
    required String bucketName,
    required String path,
    required File file,
  }) async {
    try {
      final ext = kIsWeb ? 'png' : file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath = path.isEmpty ? fileName : '$path/$fileName';
      await _supabase.storage.from(bucketName).upload(filePath, file);
      return _supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      print('Supabase upload error: $e');
      return null;
    }
  }

  /// Upload multiple files.
  Future<List<String>> uploadFiles({
    required String bucketName,
    required String path,
    required List<File> files,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = kIsWeb ? 'png' : file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.$ext';
      final filePath = path.isEmpty ? fileName : '$path/$fileName';
      try {
        await _supabase.storage.from(bucketName).upload(filePath, file);
        urls.add(_supabase.storage.from(bucketName).getPublicUrl(filePath));
      } catch (e) {
        print('Supabase multi-upload error (file $i): $e');
      }
    }
    return urls;
  }

  /// Get public URL for a stored file.
  String getPublicUrl({
    required String bucketName,
    required String path,
  }) =>
      _supabase.storage.from(bucketName).getPublicUrl(path);

  /// Delete one file.
  Future<bool> deleteFile({
    required String bucketName,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucketName).remove([path]);
      return true;
    } catch (e) {
      print('Supabase delete error: $e');
      return false;
    }
  }

  /// Delete multiple files.
  Future<bool> deleteFiles({
    required String bucketName,
    required List<String> paths,
  }) async {
    try {
      await _supabase.storage.from(bucketName).remove(paths);
      return true;
    } catch (e) {
      print('Supabase multi-delete error: $e');
      return false;
    }
  }
}
