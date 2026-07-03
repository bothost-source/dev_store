import 'package:cloud_firestore/cloud_firestore.dart';

class AppModel {
  final String id;
  final String name;
  final String packageName;
  final String description;
  final String developerId;
  final String developerName;
  final String category;
  final List<String> tags;
  final String version;
  final String minAndroidVersion;
  final int apkSize;
  final String iconUrl;
  final List<String> screenshotUrls;
  final String apkUrl;
  final String status; // pending, approved, rejected
  final String bucket;
  final String storagePath;
  final int downloadCount;
  final double averageRating;
  final int reviewCount;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  AppModel({
    required this.id,
    required this.name,
    required this.packageName,
    required this.description,
    required this.developerId,
    required this.developerName,
    required this.category,
    required this.tags,
    required this.version,
    required this.minAndroidVersion,
    required this.apkSize,
    required this.iconUrl,
    required this.screenshotUrls,
    required this.apkUrl,
    required this.status,
    required this.bucket,
    required this.storagePath,
    this.downloadCount = 0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.rejectionReason,
  });

  factory AppModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppModel(
      id: doc.id,
      name: data['name'] ?? '',
      packageName: data['packageName'] ?? '',
      description: data['description'] ?? '',
      developerId: data['developerId'] ?? '',
      developerName: data['developerName'] ?? '',
      category: data['category'] ?? 'Other',
      tags: List<String>.from(data['tags'] ?? []),
      version: data['version'] ?? '1.0.0',
      minAndroidVersion: data['minAndroidVersion'] ?? '5.0',
      apkSize: data['apkSize'] ?? 0,
      iconUrl: data['iconUrl'] ?? '',
      screenshotUrls: List<String>.from(data['screenshotUrls'] ?? []),
      apkUrl: data['apkUrl'] ?? '',
      status: data['status'] ?? 'pending',
      bucket: data['bucket'] ?? '',
      storagePath: data['storagePath'] ?? '',
      downloadCount: data['downloadCount'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'packageName': packageName,
      'description': description,
      'developerId': developerId,
      'developerName': developerName,
      'category': category,
      'tags': tags,
      'version': version,
      'minAndroidVersion': minAndroidVersion,
      'apkSize': apkSize,
      'iconUrl': iconUrl,
      'screenshotUrls': screenshotUrls,
      'apkUrl': apkUrl,
      'status': status,
      'bucket': bucket,
      'storagePath': storagePath,
      'downloadCount': downloadCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (approvedAt != null) 'approvedAt': Timestamp.fromDate(approvedAt!),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
    };
  }

  AppModel copyWith({
    String? id,
    String? name,
    String? packageName,
    String? description,
    String? developerId,
    String? developerName,
    String? category,
    List<String>? tags,
    String? version,
    String? minAndroidVersion,
    int? apkSize,
    String? iconUrl,
    List<String>? screenshotUrls,
    String? apkUrl,
    String? status,
    String? bucket,
    String? storagePath,
    int? downloadCount,
    double? averageRating,
    int? reviewCount,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return AppModel(
      id: id ?? this.id,
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      description: description ?? this.description,
      developerId: developerId ?? this.developerId,
      developerName: developerName ?? this.developerName,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      version: version ?? this.version,
      minAndroidVersion: minAndroidVersion ?? this.minAndroidVersion,
      apkSize: apkSize ?? this.apkSize,
      iconUrl: iconUrl ?? this.iconUrl,
      screenshotUrls: screenshotUrls ?? this.screenshotUrls,
      apkUrl: apkUrl ?? this.apkUrl,
      status: status ?? this.status,
      bucket: bucket ?? this.bucket,
      storagePath: storagePath ?? this.storagePath,
      downloadCount: downloadCount ?? this.downloadCount,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
