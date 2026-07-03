import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // user, developer, admin
  final bool isDeveloper;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> installedApps;
  final List<String> favoriteApps;
  final Map<String, dynamic>? developerProfile;

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
      developerProfile: data['developerProfile'],
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
      if (developerProfile != null) 'developerProfile': developerProfile,
    };
  }

  bool get isAdmin => role == 'admin';
}
