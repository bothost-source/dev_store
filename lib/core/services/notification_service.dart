import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Navigate to relevant screen based on message data
    final data = message.data;
    if (data['type'] == 'app_update') {
      // Navigate to app detail screen
    } else if (data['type'] == 'new_app') {
      // Navigate to new apps screen
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'devstore_channel',
      'DEVSTORE Notifications',
      channelDescription: 'Notifications for app updates and new releases',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  // Subscribe to topics
  Future<void> subscribeToAppUpdates(String appId) async {
    await _messaging.subscribeToTopic('app_$appId');
  }

  Future<void> unsubscribeFromAppUpdates(String appId) async {
    await _messaging.unsubscribeFromTopic('app_$appId');
  }

  Future<void> subscribeToNewApps() async {
    await _messaging.subscribeToTopic('new_apps');
  }

  Future<void> subscribeToPromotions() async {
    await _messaging.subscribeToTopic('promotions');
  }
}

// Background message handler (must be top-level function)
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // Handle background message
  print('Background message: ${message.notification?.title}');
}
