import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import 'supabase_storage_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseStorageService _storageService = SupabaseStorageService();
  
  static const String _bucketName = 'user-profiles';

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

  Future<User?> getCurrentUser() async {
    // TODO: Replace with actual user ID retrieval (e.g., from auth service)
    final userId = 'current_user_id';
    return getUserById(userId);
  }

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

  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      final url = await _storageService.uploadFile(
        bucketName: _bucketName,
        path: userId,
        file: imageFile,
      );
      
      if (url != null) {
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

  Future<Address?> addAddress({
    required String userId,
    required String name,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    String? phone,
    bool isDefault = false,
  }) async {
    try {
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
        id: '',
        userId: userId,
        name: name,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        phone: phone,
        isDefault: isDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('addresses').add(addressData.toMap());
      await _firestore.collection('users').doc(userId).update({
        'addresses': FieldValue.arrayUnion([docRef.id]),
      });
      return addressData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding address: $e');
      return null;
    }
  }

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

  Future<bool> updateAddress({
    required String addressId,
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? phone,
    bool? isDefault,
  }) async {
    try {
      final addressRef = _firestore.collection('addresses').doc(addressId);
      final addressDoc = await addressRef.get();
      
      if (!addressDoc.exists) return false;
      
      final address = Address.fromMap(addressDoc.data()!, addressDoc.id);
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
        phone: phone,
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

  Future<bool> deleteAddress(String addressId) async {
    try {
      final addressRef = _firestore.collection('addresses').doc(addressId);
      final addressDoc = await addressRef.get();
      
      if (!addressDoc.exists) return false;
      
      final address = Address.fromMap(addressDoc.data()!, addressDoc.id);
      await _firestore.collection('users').doc(address.userId).update({
        'addresses': FieldValue.arrayRemove([addressId]),
      });
      await addressRef.delete();
      return true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

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
        id: '',
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
      await _firestore.collection('users').doc(userId).update({
        'paymentMethods': FieldValue.arrayUnion([docRef.id]),
      });
      return paymentMethodData.copyWith(id: docRef.id);
    } catch (e) {
      print('Error adding payment method: $e');
      return null;
    }
  }

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

  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      final paymentMethodRef = _firestore.collection('paymentMethods').doc(paymentMethodId);
      final paymentMethodDoc = await paymentMethodRef.get();
      
      if (!paymentMethodDoc.exists) return false;
      
      final paymentMethod = PaymentMethod.fromMap(paymentMethodDoc.data()!, paymentMethodDoc.id);
      await _firestore.collection('users').doc(paymentMethod.userId).update({
        'paymentMethods': FieldValue.arrayRemove([paymentMethodId]),
      });
      await paymentMethodRef.delete();
      return true;
    } catch (e) {
      print('Error deleting payment method: $e');
      return false;
    }
  }
}