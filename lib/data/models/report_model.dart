import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String appId;
  final String appName;
  final String reporterId;
  final String reporterName;
  final String reason;
  final String? details;
  final String status; // pending, resolved, dismissed
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolution;

  ReportModel({
    required this.id,
    required this.appId,
    required this.appName,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    this.details,
    this.status = 'pending',
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      appId: data['appId'] ?? '',
      appName: data['appName'] ?? '',
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? '',
      reason: data['reason'] ?? '',
      details: data['details'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      resolvedBy: data['resolvedBy'],
      resolution: data['resolution'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appId': appId,
      'appName': appName,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reason': reason,
      'details': details,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
      'resolvedBy': resolvedBy,
      'resolution': resolution,
    };
  }
}
