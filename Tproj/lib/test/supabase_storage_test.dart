// File: lib/test/supabase_storage_test.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_storage_service.dart';

// This is a manual test file that can be used to test the Supabase Storage implementation
// It's not meant to be run as an automated test, but rather as a guide for manual testing

void main() {
  // Initialize Supabase before running tests
  setUp(() async {
    await SupabaseStorageService.initialize(
      supabaseUrl: 'YOUR_SUPABASE_URL',
      supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
  });

  // Test uploading a single file
  testWidgets('Test uploading a single file', (WidgetTester tester) async {
    // This is a manual test that requires a real device or emulator
    // 1. Pick an image from the device
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // 2. Upload the image to Supabase Storage
      final storageService = SupabaseStorageService();
      final url = await storageService.uploadFile(
        bucketName: 'test-bucket',
        path: 'test',
        file: File(image.path),
      );
      
      // 3. Verify that the URL is not null
      expect(url, isNotNull);
      print('Uploaded file URL: $url');
    } else {
      fail('No image selected');
    }
  });

  // Test uploading multiple files
  testWidgets('Test uploading multiple files', (WidgetTester tester) async {
    // This is a manual test that requires a real device or emulator
    // 1. Pick multiple images from the device
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      // 2. Convert XFile to File
      final List<File> files = images.map((image) => File(image.path)).toList();
      
      // 3. Upload the images to Supabase Storage
      final storageService = SupabaseStorageService();
      final urls = await storageService.uploadFiles(
        bucketName: 'test-bucket',
        path: 'test-multiple',
        files: files,
      );
      
      // 4. Verify that the URLs list is not empty
      expect(urls, isNotEmpty);
      print('Uploaded file URLs: $urls');
    } else {
      fail('No images selected');
    }
  });

  // Test getting a public URL
  test('Test getting a public URL', () {
    final storageService = SupabaseStorageService();
    final url = storageService.getPublicUrl(
      bucketName: 'test-bucket',
      path: 'test/image.jpg',
    );
    
    // Verify that the URL is not null or empty
    expect(url, isNotEmpty);
    print('Public URL: $url');
  });

  // Test deleting a file
  testWidgets('Test deleting a file', (WidgetTester tester) async {
    // This test assumes that a file has been uploaded in a previous test
    // 1. Delete the file from Supabase Storage
    final storageService = SupabaseStorageService();
    final success = await storageService.deleteFile(
      bucketName: 'test-bucket',
      path: 'test/image.jpg',
    );
    
    // 2. Verify that the deletion was successful
    expect(success, isTrue);
    print('File deleted successfully');
  });
}

// Manual testing steps:
// 1. Create a Supabase project and configure it
// 2. Create a bucket named 'test-bucket' in Supabase Storage
// 3. Set up the appropriate storage policies for the bucket
// 4. Update the Supabase URL and anon key in the test file
// 5. Run the tests manually on a device or emulator
// 6. Verify that the files are uploaded and accessible in the Supabase dashboard
// 7. Verify that the files can be deleted from Supabase Storage
