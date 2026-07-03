import 'package:cloud_firestore/cloud_firestore.dart';

class DeveloperProfile {
  final String? bio;
  final String? website;
  final String? githubUrl;
  final String? company;
  final bool isVerified;
  final DateTime? joinedAt;

  DeveloperProfile({
    this.bio,
    this.website,
    this.githubUrl,
    this.company,
    this.isVerified = false,
    this.joinedAt,
  });

  factory DeveloperProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return DeveloperProfile();
    return DeveloperProfile(
      bio: map['bio'],
      website: map['website'],
      githubUrl: map['githubUrl'],
      company: map['company'],
      isVerified: map['isVerified'] ?? false,
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (bio != null) 'bio': bio,
      if (website != null) 'website': website,
      if (githubUrl != null) 'githubUrl': githubUrl,
      if (company != null) 'company': company,
      'isVerified': isVerified,
      if (joinedAt != null) 'joinedAt': Timestamp.fromDate(joinedAt!),
    };
  }
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;
  final bool isDeveloper;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> installedApps;
  final List<String> favoriteApps;
  final DeveloperProfile? developerProfile;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    this.isDeveloper = false,
    required this.createdAt,
    required this.lastLoginAt,
    this.installedApps = const [],
    this.favoriteApps = const [],
    this.developerProfile,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'user',
      isDeveloper: data['isDeveloper'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      installedApps: List<String>.from(data['installedApps'] ?? []),
      favoriteApps: List<String>.from(data['favoriteApps'] ?? []),
      developerProfile: DeveloperProfile.fromMap(data['developerProfile']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'isDeveloper': isDeveloper,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'installedApps': installedApps,
      'favoriteApps': favoriteApps,
      if (developerProfile != null) 'developerProfile': developerProfile!.toMap(),
    };
  }

  bool get isAdmin => role == 'admin';
}
