import 'package:cloud_firestore/cloud_firestore.dart';

class DeveloperProfile {
  final String userId;
  final String companyName;
  final String? website;
  final String? bio;
  final int totalApps;
  final int totalDownloads;
  final double averageRating;
  final bool isVerified;
  final DateTime joinedAt;

  DeveloperProfile({
    required this.userId,
    required this.companyName,
    this.website,
    this.bio,
    this.totalApps = 0,
    this.totalDownloads = 0,
    this.averageRating = 0.0,
    this.isVerified = false,
    required this.joinedAt,
  });

  factory DeveloperProfile.fromMap(Map<String, dynamic> map) {
    return DeveloperProfile(
      userId: map['userId'] ?? '',
      companyName: map['companyName'] ?? '',
      website: map['website'],
      bio: map['bio'],
      totalApps: map['totalApps'] ?? 0,
      totalDownloads: map['totalDownloads'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      isVerified: map['isVerified'] ?? false,
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'companyName': companyName,
      'website': website,
      'bio': bio,
      'totalApps': totalApps,
      'totalDownloads': totalDownloads,
      'averageRating': averageRating,
      'isVerified': isVerified,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}
