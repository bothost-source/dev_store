import 'package:cloud_firestore/cloud_firestore.dart';
import ' ../models/user_model.dart';
import '../models/report_model.dart';
import '../../core/constants/app_constants.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // Get developers
  Stream<List<UserModel>> getDevelopers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('isDeveloper', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  // Ban/unban user
  Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'role': role,
    });
  }

  // Add to installed apps
  Future<void> addInstalledApp(String uid, String appId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'installedApps': FieldValue.arrayUnion([appId]),
    });
  }

  // Remove from installed apps
  Future<void> removeInstalledApp(String uid, String appId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'installedApps': FieldValue.arrayRemove([appId]),
    });
  }

  // Add to favorites
  Future<void> addFavorite(String uid, String appId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'favoriteApps': FieldValue.arrayUnion([appId]),
    });
  }

  // Remove from favorites
  Future<void> removeFavorite(String uid, String appId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'favoriteApps': FieldValue.arrayRemove([appId]),
    });
  }

  // Get user favorites
  Future<List<String>> getUserFavorites(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists) {
      return List<String>.from(doc.data()?['favoriteApps'] ?? []);
    }
    return [];
  }

  // Report app
  Future<void> reportApp(ReportModel report) async {
    final docRef = _firestore.collection(AppConstants.reportsCollection).doc();
    await docRef.set(report.copyWith(id: docRef.id).toFirestore());
  }

  // Get all reports
  Stream<List<ReportModel>> getAllReports() {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
    });
  }

  // Get pending reports
  Stream<List<ReportModel>> getPendingReports() {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
    });
  }

  // Resolve report
  Future<void> resolveReport(String reportId, String resolvedBy, String resolution) async {
    await _firestore.collection(AppConstants.reportsCollection).doc(reportId).update({
      'status': 'resolved',
      'resolvedAt': Timestamp.fromDate(DateTime.now()),
      'resolvedBy': resolvedBy,
      'resolution': resolution,
    });
  }

  // Dismiss report
  Future<void> dismissReport(String reportId, String resolvedBy) async {
    await _firestore.collection(AppConstants.reportsCollection).doc(reportId).update({
      'status': 'dismissed',
      'resolvedAt': Timestamp.fromDate(DateTime.now()),
      'resolvedBy': resolvedBy,
      'resolution': 'Dismissed by admin',
    });
  }

  // Get analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    final usersCount = await _firestore.collection(AppConstants.usersCollection).count().get();
    final appsCount = await _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusApproved)
        .count()
        .get();
    final developersCount = await _firestore
        .collection(AppConstants.usersCollection)
        .where('isDeveloper', isEqualTo: true)
        .count()
        .get();
    final pendingCount = await _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusPending)
        .count()
        .get();

    // Get total downloads
    final appsSnapshot = await _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusApproved)
        .get();

    int totalDownloads = 0;
    for (final doc in appsSnapshot.docs) {
      totalDownloads += (doc.data()['downloadCount'] ?? 0) as int;
    }

    return {
      'totalUsers': usersCount.count,
      'totalApps': appsCount.count,
      'totalDevelopers': developersCount.count,
      'pendingApps': pendingCount.count,
      'totalDownloads': totalDownloads,
    };
  }
}

extension on ReportModel {
  ReportModel copyWith({String? id}) {
    return ReportModel(
      id: id ?? this.id,
      appId: appId,
      appName: appName,
      reporterId: reporterId,
      reporterName: reporterName,
      reason: reason,
      details: details,
      status: status,
      createdAt: createdAt,
      resolvedAt: resolvedAt,
      resolvedBy: resolvedBy,
      resolution: resolution,
    );
  }
}
