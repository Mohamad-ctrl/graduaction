import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../models/address.dart'; // Import Address model
import '../models/payment_method.dart'; // Import PaymentMethod model

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final String _collection = 'users';

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;
      
      return getUserById(currentUser.uid);
    } catch (e) {
      // print('Error getting current user: $e'); // Removed print
      return null;
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      // print('Error getting user by ID: $e'); // Removed print
      return null;
    }
  }

  // Update user profile
  Future<User?> updateUserProfile({
    required String userId,
    String? username,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final userRef = _firestore.collection(_collection).doc(userId);
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) return null;
      
      final userData = User.fromMap(userDoc.data()!, userDoc.id);
      final updatedUser = userData.copyWith(
        username: username,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );
      
      await userRef.update(updatedUser.toMap());
      return updatedUser;
    } catch (e) {
      // print('Error updating user profile: $e'); // Removed print
      return null;
    }
  }

  // Get user addresses
  Future<List<Address>> getUserAddresses() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];
      
      final snapshot = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      
      return snapshot.docs.map((doc) => Address.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // print('Error getting user addresses: $e'); // Removed print
      return [];
    }
  }

  // Add user address
  Future<bool> addUserAddress({
    required String name,
    required String street,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    String? addressLine2,
    String? phone,
    bool isDefault = false,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      // If this is the default address, update all other addresses to non-default
      if (isDefault) {
        final addressesSnapshot = await _firestore
            .collection('addresses')
            .where('userId', isEqualTo: currentUser.uid)
            .where('isDefault', isEqualTo: true)
            .get();
        
        for (var doc in addressesSnapshot.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }
      
      // Create new address
      await _firestore.collection('addresses').add({
        'userId': currentUser.uid,
        'name': name,
        'addressLine1': street,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'phone': phone,
        'isDefault': isDefault,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      
      return true;
    } catch (e) {
      // print('Error adding user address: $e'); // Removed print
      return false;
    }
  }

  // Get user payment methods
  Future<List<PaymentMethod>> getUserPaymentMethods() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];
      
      final snapshot = await _firestore
          .collection('paymentMethods')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      
      return snapshot.docs.map((doc) => PaymentMethod.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // print('Error getting user payment methods: $e'); // Removed print
      return [];
    }
  }

  // Add user payment method
  Future<bool> addUserPaymentMethod({
    required String cardType,
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    bool isDefault = false,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      // If this is the default payment method, update all other payment methods to non-default
      if (isDefault) {
        final paymentMethodsSnapshot = await _firestore
            .collection('paymentMethods')
            .where('userId', isEqualTo: currentUser.uid)
            .where('isDefault', isEqualTo: true)
            .get();
        
        for (var doc in paymentMethodsSnapshot.docs) {
          await doc.reference.update({'isDefault': false});
        }
      }
      
      // Create new payment method
      await _firestore.collection('paymentMethods').add({
        'userId': currentUser.uid,
        'cardType': cardType,
        'cardNumber': cardNumber,
        'cardHolderName': cardHolderName,
        'expiryDate': expiryDate,
        'isDefault': isDefault,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      
      return true;
    } catch (e) {
      // print('Error adding user payment method: $e'); // Removed print
      return false;
    }
  }

  // Update user profile image
  Future<bool> updateUserProfileImage({
    required String imageUrl,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      await _firestore.collection(_collection).doc(currentUser.uid).update({
        'profileImageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      // print('Error updating user profile image: $e'); // Removed print
      return false;
    }
  }

  // Get all users (admin function)
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // print('Error getting all users: $e'); // Removed print
      return [];
    }
  }
}
