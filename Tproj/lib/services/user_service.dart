// File: lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user.dart';
import '../models/address.dart';
import '../models/payment_method.dart';

class UserService {
  // ────────────────────────────────────────────────────────────
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  /// top-level users collection name
  final String _collection = 'users';

  // ───────────────  BASE USER HELPERS  ───────────────
  Future<User?> getCurrentUser() async {
    try {
      final current = _auth.currentUser;
      if (current == null) return null;
      return getUserById(current.uid);
    } catch (_) {
      return null;
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      return doc.exists ? User.fromMap(doc.data()!, doc.id) : null;
    } catch (_) {
      return null;
    }
  }

  Future<User?> updateUserProfile({
    required String userId,
    String? username,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final ref = _firestore.collection(_collection).doc(userId);
      final snap = await ref.get();
      if (!snap.exists) return null;

      final user = User.fromMap(snap.data()!, snap.id).copyWith(
        username: username,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await ref.update(user.toMap());
      return user;
    } catch (_) {
      return null;
    }
  }

  // ───────────────────────  ADMIN  ───────────────────────
  Future<bool> isUserAdmin(String userId) async {
    final adminDoc =
        await _firestore.collection('admins').doc(userId).get(); // simple flag
    return adminDoc.exists;
  }

  // ───────────────  ADDRESS CRUD (MODEL-BASED)  ───────────────
  Future<Address> addAddress(Address address) async {
    final doc =
        await _firestore.collection('addresses').add(address.toMap());
    return address.copyWith(id: doc.id);
  }

  Future<void> updateAddress(Address address) => _firestore
      .collection('addresses')
      .doc(address.id)
      .update(address.toMap());

  Future<void> deleteAddress(String id) =>
      _firestore.collection('addresses').doc(id).delete();

  Future<void> setDefaultAddress(String id) async {
    final batch = _firestore.batch();
    final snap = await _firestore.collection('addresses').get();
    for (final d in snap.docs) {
      batch.update(d.reference, {'isDefault': d.id == id});
    }
    await batch.commit();
  }

  Future<List<Address>> getUserAddresses() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _firestore
        .collection('addresses')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Address.fromMap(d.data(), d.id)).toList();
  }

  // ───────────────  PAYMENT-METHOD CRUD  ───────────────
  Future<PaymentMethod> addPaymentMethod(PaymentMethod pm) async {
    final doc =
        await _firestore.collection('paymentMethods').add(pm.toMap());
    return pm.copyWith(id: doc.id);
  }

  Future<void> updatePaymentMethod(PaymentMethod pm) => _firestore
      .collection('paymentMethods')
      .doc(pm.id)
      .update(pm.toMap());

  Future<void> deletePaymentMethod(String id) =>
      _firestore.collection('paymentMethods').doc(id).delete();

  Future<void> setDefaultPaymentMethod(String id) async {
    final batch = _firestore.batch();
    final snap = await _firestore.collection('paymentMethods').get();
    for (final d in snap.docs) {
      batch.update(d.reference, {'isDefault': d.id == id});
    }
    await batch.commit();
  }

  Future<List<PaymentMethod>> getUserPaymentMethods() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _firestore
        .collection('paymentMethods')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => PaymentMethod.fromMap(d.data(), d.id))
        .toList();
  }

  // ───────────────  UTILITY / ADMIN LISTS  ───────────────
  Future<List<User>> getAllUsers() async {
    final snap = await _firestore.collection(_collection).get();
    return snap.docs.map((d) => User.fromMap(d.data(), d.id)).toList();
  }

  /// Convenience wrapper preserved from your old API layer
  /// (keeps older calls compiling while you migrate)
  // ADDRESSES (param-style)
  @deprecated
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
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final addr = Address(
      id: '',
      userId: uid,
      name: name,
      addressLine1: street,
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

    await addAddress(addr);
    if (isDefault) await setDefaultAddress(addr.id);
    return true;
  }

  // PAYMENT METHODS (param-style)
  @deprecated
  Future<bool> addUserPaymentMethod({
    required String cardType,
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
    String? cvv,
    bool isDefault = false,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final pm = PaymentMethod(
      id: '',
      userId: uid,
      cardType: cardType,
      cardNumber: cardNumber,
      cardholderName: cardHolderName,
      expiryDate: expiryDate,
      cvv: cvv,
      isDefault: isDefault,
    );

    await addPaymentMethod(pm);
    if (isDefault) await setDefaultPaymentMethod(pm.id);
    return true;
  }
}
