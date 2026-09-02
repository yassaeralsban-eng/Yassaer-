import '../entities/user.dart';

/// Contract for authentication operations (SAD section 17).
abstract interface class AuthRepository {
  /// Returns the currently signed-in user, or null.
  User? get currentUser;

  /// Stream of auth state changes.
  Stream<User?> authStateChanges();

  /// Signs in with phone number verification.
  Future<User> signInWithPhone(String phone);

  /// Signs out the current user.
  Future<void> signOut();

  /// Updates the user profile (displayName, photoUrl).
  Future<User> updateProfile({String? displayName, String? photoUrl});
}
