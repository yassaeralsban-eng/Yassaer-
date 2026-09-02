import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Firebase implementation of [AuthRepository] (SAD section 17).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? fb.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  User? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _userFromFirebase(user);
  }

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges().map(
    (user) => user == null ? null : _userFromFirebase(user),
  );

  @override
  Future<User> signInWithPhone(String phone) async {
    // In production this uses Firebase Phone Auth with OTP.
    // For the MVP we create/update the user document directly.
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      throw StateError('يجب تسجيل الدخول أولاً');
    }

    final doc = _firestore.collection('users').doc(fbUser.uid);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      final now = DateTime.now();
      final model = UserModel(
        id: fbUser.uid,
        displayName: fbUser.displayName ?? 'مستخدم جديد',
        phone: phone,
        photoUrl: fbUser.photoURL,
        role: UserRole.user,
        trustScore: 0,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      await doc.set(model.toMap());
      return model.toEntity();
    }

    final model = UserModel.fromMap(snapshot.data()!);
    return model.toEntity();
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<User> updateProfile({String? displayName, String? photoUrl}) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      throw StateError('يجب تسجيل الدخول أولاً');
    }

    if (displayName != null) {
      await fbUser.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await fbUser.updatePhotoURL(photoUrl);
    }

    final doc = _firestore.collection('users').doc(fbUser.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      throw StateError('حساب المستخدم غير موجود');
    }

    final model = UserModel.fromMap(snapshot.data()!);
    final updated = model.toEntity().copyWith(
      displayName: displayName,
      photoUrl: photoUrl,
      updatedAt: DateTime.now(),
    );
    await doc.update(UserModel.fromEntity(updated).toMap());
    return updated;
  }

  User _userFromFirebase(fb.User user) => User(
    id: user.uid,
    displayName: user.displayName ?? 'مستخدم',
    phone: user.phoneNumber ?? '',
    photoUrl: user.photoURL,
    role: UserRole.user,
    trustScore: 0,
    status: UserStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
