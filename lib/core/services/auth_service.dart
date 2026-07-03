import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart'; 
import '../constants/app_constants.dart';    

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
    bool isDeveloper = false,
    DeveloperProfile? developerProfile,  // ✅ CHANGED: was Map<String, dynamic>?
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);

        final userData = UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          role: isDeveloper ? AppConstants.roleDeveloper : AppConstants.roleUser,
          isDeveloper: isDeveloper,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          developerProfile: developerProfile,  // ✅ Now matches DeveloperProfile? type
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(userData.toFirestore());

        return userData;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
    return null;
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .update({'lastLoginAt': Timestamp.fromDate(DateTime.now())});

        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Data
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Update User
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  // Become Developer
  Future<void> becomeDeveloper(String uid, DeveloperProfile profile) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'isDeveloper': true,
      'role': AppConstants.roleDeveloper,
      'developerProfile': profile.toMap(),
    });
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Change Password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
