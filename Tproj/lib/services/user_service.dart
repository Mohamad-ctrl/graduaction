// File: lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import 'supabase_storage_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseStorageService _storageService = SupabaseStorageService();
  
  // Bucket name for user profile images
  static const String _bucketName = 'user-profiles';

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? username,
    String? phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        if (username != null) 'username': username,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Upload image to Supabase Storage
      final url = await _storageService.uploadFile(
        bucketName: _bucketName,
        path: userId,
        file: imageFile,
      );
      
      if (url != null) {
        // Update user profile with image URL
        await _firestore.collection('users').doc(userId).update({
          'profileImageUrl': url,
          'updatedAt': DateTime.now(),
        });
      }
      
      return url;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Add address
  Future<Address?> addAddress({
    required String userId,
    required String name,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    bool isDefault = false,
  }) async {
    try {
      // If this is the default address, update all other addresses to non-default
      if (isDefault) {
        final querySnapshot = await _firestore
            .collection('addresses')
            .where('userId', isEqualTo: userId)
            .where('isDefault', isEqualTo: true)
            .get();
        
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }
      
      final addressData = Address(
        id: '', // Will be set after document creation
        userId: userId,
        name: name,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        isDefault: isDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('addresses').add(addressData.toMap());
      
      // Add address ID to user's addresses list
      await _firestore.collection('users').doc(userId).update({
        'addresses': FieldValue.arrayUnion([docRef.id]),
      });
      
      return addressData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding address: $e');
      return null;
    }
  }

  // Get user addresses
  Future<List<Address>> getUserAddresses(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return Address.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error getting user addresses: $e');
      return [];
    }
  }

  // Update address
  Future<bool> updateAddress({
    required String addressId,
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
  }) async {
    try {
      final addressRef = _firestore.collection('addresses').doc(addressId);
      final addressDoc = await addressRef.get();
      
      if (!addressDoc.exists) return false;
      
      final address = Address.fromMap(addressDoc.data()!, addressDoc.id);
      
      // If setting as default, update all other addresses to non-default
      if (isDefault == true && !address.isDefault) {
        final querySnapshot = await _firestore
            .collection('addresses')
            .where('userId', isEqualTo: address.userId)
            .where('isDefault', isEqualTo: true)
            .get();
        
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }
      
      final updatedAddress = address.copyWith(
        name: name,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        isDefault: isDefault,
        updatedAt: DateTime.now(),
      );
      
      await addressRef.update(updatedAddress.toMap());
      return true;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      final addressRef = _firestore.collection('addresses').doc(addressId);
      final addressDoc = await addressRef.get();
      
      if (!addressDoc.exists) return false;
      
      final address = Address.fromMap(addressDoc.data()!, addressDoc.id);
      
      // Remove address ID from user's addresses list
      await _firestore.collection('users').doc(address.userId).update({
        'addresses': FieldValue.arrayRemove([addressId]),
      });
      
      // Delete address document
      await addressRef.delete();
      return true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Add payment method
  Future<PaymentMethod?> addPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required String name,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    bool isDefault = false,
  }) async {
    try {
      // If this is the default payment method, update all other payment methods to non-default
      if (isDefault) {
        final querySnapshot = await _firestore
            .collection('paymentMethods')
            .where('userId', isEqualTo: userId)
            .where('isDefault', isEqualTo: true)
            .get();
        
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }
      
      final paymentMethodData = PaymentMethod(
        id: '', // Will be set after document creation
        userId: userId,
        type: type,
        name: name,
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        expiryDate: expiryDate,
        isDefault: isDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('paymentMethods').add(paymentMethodData.toMap());
      
      // Add payment method ID to user's payment methods list
      await _firestore.collection('users').doc(userId).update({
        'paymentMethods': FieldValue.arrayUnion([docRef.id]),
      });
      
      return paymentMethodData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding payment method: $e');
      return null;
    }
  }

  // Get user payment methods
  Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('paymentMethods')
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return PaymentMethod.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error getting user payment methods: $e');
      return [];
    }
  }

  // Delete payment method
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      final paymentMethodRef = _firestore.collection('paymentMethods').doc(paymentMethodId);
      final paymentMethodDoc = await paymentMethodRef.get();
      
      if (!paymentMethodDoc.exists) return false;
      
      final paymentMethod = PaymentMethod.fromMap(paymentMethodDoc.data()!, paymentMethodDoc.id);
      
      // Remove payment method ID from user's payment methods list
      await _firestore.collection('users').doc(paymentMethod.userId).update({
        'paymentMethods': FieldValue.arrayRemove([paymentMethodId]),
      });
      
      // Delete payment method document
      await paymentMethodRef.delete();
      return true;
    } catch (e) {
      print('Error deleting payment method: $e');
      return false;
    }
  }
}
