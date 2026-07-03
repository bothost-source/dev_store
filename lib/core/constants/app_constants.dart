class AppConstants {
  // App Info
  static const String appName = 'DEVSTORE';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Discover Amazing Apps in devstore built by DevForge';

  // Storj Configuration
  static const String storjAccessKey = 'jvlwtebn7jgclcscjvu33pppy32q';
  // NOTE: Secret key should be stored securely - in production use Firebase Secrets or environment variables
  static const String storjEndpoint = 'https://gateway.storjshare.io';
  static const String storjPublicBase = 'https://link.storjshare.io/s';
  static const List<String> storjBuckets = [
    'devstore-apps-1',
    'devstore-apps-2',
  ];

  // Storage Folders
  static const String pendingFolder = 'pending';
  static const String approvedFolder = 'approved';
  static const String rejectedFolder = 'rejected';

  // Firebase Collections
  static const String appsCollection = 'apps';
  static const String developersCollection = 'developers';
  static const String reviewsCollection = 'reviews';
  static const String reportsCollection = 'reports';
  static const String usersCollection = 'users';
  static const String categoriesCollection = 'categories';
  static const String systemCollection = 'system';

  // App Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // User Roles
  static const String roleUser = 'user';
  static const String roleDeveloper = 'developer';
  static const String roleAdmin = 'admin';

  // Categories
  static const List<String> appCategories = [
    'All',
    'Games',
    'Productivity',
    'Social',
    'Entertainment',
    'Education',
    'Finance',
    'Health & Fitness',
    'Music & Audio',
    'Photography',
    'Shopping',
    'Tools',
    'Travel',
    'Communication',
    'News & Magazines',
  ];

  // File Limits
  static const int maxApkSize = 500 * 1024 * 1024; // 500MB
  static const int maxIconSize = 5 * 1024 * 1024; // 5MB
  static const int maxScreenshotSize = 10 * 1024 * 1024; // 10MB
  static const int maxScreenshots = 8;

  // Download
  static const int downloadTimeoutSeconds = 300; // 5 minutes
  static const int presignedUrlExpiryHours = 24;

  // Pagination
  static const int appsPerPage = 20;
  static const int reviewsPerPage = 10;

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);
}
