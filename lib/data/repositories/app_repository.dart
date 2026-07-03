import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/app_model.dart';
import '../models/review_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storj_service.dart';

class AppRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final StorjService _storjService = StorjService();

  // Create app (pending approval)
  Future<AppModel> createApp(AppModel app) async {
    final docRef = _firestore.collection(AppConstants.appsCollection).doc();
    final appWithId = app.copyWith(id: docRef.id);
    await docRef.set(appWithId.toFirestore());
    return appWithId;
  }

  // Get approved apps (for public store)
  Stream<List<AppModel>> getApprovedApps({
    String? category,
    String? searchQuery,
    String sortBy = 'createdAt',
    bool descending = true,
    int limit = AppConstants.appsPerPage,
  }) {
    Query query = _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusApproved)
        .orderBy(sortBy, descending: descending);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
                   .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
    });
  }

  // Get featured apps
  Stream<List<AppModel>> getFeaturedApps() {
    return _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusApproved)
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
    });
  }

  // Get new releases
  Stream<List<AppModel>> getNewReleases() {
    return _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusApproved)
        .orderBy('approvedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
    });
  }

  // Get top charts (most downloaded)
  Stream<List<AppModel>> getTopCharts() {
    return _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusApproved)
        .orderBy('downloadCount', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
    });
  }

  // Get app by ID
  Future<AppModel?> getAppById(String appId) async {
    final doc = await _firestore
        .collection(AppConstants.appsCollection)
        .doc(appId)
        .get();
    if (doc.exists) {
      return AppModel.fromFirestore(doc);
    }
    return null;
  }

  // Get similar apps
  Future<List<AppModel>> getSimilarApps(String appId, String category) async {
    final snapshot = await _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusApproved)
        .where('category', isEqualTo: category)
        .where(FieldPath.documentId, isNotEqualTo: appId)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
  }

  // Get developer apps
  Stream<List<AppModel>> getDeveloperApps(String developerId) {
    return _firestore
        .collection(AppConstants.appsCollection)
        .where('developerId', isEqualTo: developerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
    });
  }

  // Get pending apps (for admin)
  Stream<List<AppModel>> getPendingApps() {
    return _firestore
        .collection(AppConstants.appsCollection)
        .where('status', isEqualTo: AppConstants.statusPending)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
    });
  }

  // Approve app
  Future<void> approveApp(String appId) async {
    final app = await getAppById(appId);
    if (app == null) return;

    // Move file from pending to approved in Storj
    final newPath = app.storagePath.replaceFirst(
      AppConstants.pendingFolder,
      AppConstants.approvedFolder,
    );

    // Update Firestore
    await _firestore.collection(AppConstants.appsCollection).doc(appId).update({
      'status': AppConstants.statusApproved,
      'approvedAt': Timestamp.fromDate(DateTime.now()),
      'storagePath': newPath,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Reject app
  Future<void> rejectApp(String appId, String reason) async {
    await _firestore.collection(AppConstants.appsCollection).doc(appId).update({
      'status': AppConstants.statusRejected,
      'rejectionReason': reason,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Increment download count
  Future<void> incrementDownloadCount(String appId) async {
    await _firestore.collection(AppConstants.appsCollection).doc(appId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  // Update app rating
  Future<void> updateAppRating(String appId) async {
    final reviewsSnapshot = await _firestore
        .collection(AppConstants.reviewsCollection)
        .where('appId', isEqualTo: appId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    double totalRating = 0;
    for (final doc in reviewsSnapshot.docs) {
      totalRating += (doc.data()['rating'] ?? 0.0).toDouble();
    }

    final averageRating = totalRating / reviewsSnapshot.docs.length;

    await _firestore.collection(AppConstants.appsCollection).doc(appId).update({
      'averageRating': averageRating,
      'reviewCount': reviewsSnapshot.docs.length,
    });
  }

  // Feature/unfeature app
  Future<void> toggleFeatured(String appId, bool isFeatured) async {
    await _firestore.collection(AppConstants.appsCollection).doc(appId).update({
      'isFeatured': isFeatured,
    });
  }

  // Delete app
  Future<void> deleteApp(String appId) async {
    final app = await getAppById(appId);
    if (app != null) {
      // Delete from Storj
      final parts = app.storagePath.split('/');
      if (parts.length >= 2) {
        final bucket = parts[0];
        final objectPath = parts.sublist(1).join('/');
        await _storjService.deleteFile(bucket, objectPath);
      }
    }

    // Delete from Firestore
    await _firestore.collection(AppConstants.appsCollection).doc(appId).delete();

    // Delete related reviews
    final reviews = await _firestore
        .collection(AppConstants.reviewsCollection)
        .where('appId', isEqualTo: appId)
        .get();

    for (final doc in reviews.docs) {
      await doc.reference.delete();
    }
  }

  // Get reviews for app
  Stream<List<ReviewModel>> getAppReviews(String appId) {
    return _firestore
        .collection(AppConstants.reviewsCollection)
        .where('appId', isEqualTo: appId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
    });
  }

  // Add review
  Future<void> addReview(ReviewModel review) async {
    final docRef = _firestore.collection(AppConstants.reviewsCollection).doc();
    await docRef.set(review.copyWith(id: docRef.id).toFirestore());
    await updateAppRating(review.appId);
  }

  // Delete review
  Future<void> deleteReview(String reviewId, String appId) async {
    await _firestore.collection(AppConstants.reviewsCollection).doc(reviewId).delete();
    await updateAppRating(appId);
  }
}
