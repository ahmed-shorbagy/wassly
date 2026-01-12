import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseFirestore _firestore;
  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  NotificationService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Future<void> init() async {
    if (_isInitialized) return;

    _firebaseMessaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppLogger.logInfo(
      'User granted notification permission: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Setup Local Notifications (for foreground display)
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          // Handle local notification tap
          if (details.payload != null) {
            AppLogger.logInfo(
              'Local notification tapped with payload: ${details.payload}',
            );
            // TODO: Navigate based on payload
          }
        },
      );

      // 3. Create Channel (Android)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.max,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // 4. Foreground Message Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        // If `onMessage` is triggered with a notification, construct our own
        // local notification to show to users using the created channel.
        if (notification != null && android != null) {
          _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
                priority: Priority.high,
                importance: Importance.max,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });

      // 5. Background Message Handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 6. Handle Interaction (Open App)
      // Get any messages which caused the application to open from
      // a terminated state.
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();

      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      // Also handle any interaction when the app is in the background via a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      _isInitialized = true;
    }
  }

  void _handleMessage(RemoteMessage message) {
    AppLogger.logInfo('Notification clicked! Data: ${message.data}');
    // TODO: Implement navigation routing
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> saveTokenToDatabase(String userId, String appType) async {
    // appType: 'customer', 'admin', 'partner' (driver is usually partner or driver app)
    try {
      String? token = await getToken();
      if (token != null) {
        // We'll store tokens in a subcollection or a field.
        // Storing in a field 'fcmToken' is simple but only supports one device.
        // Storing in a 'fcmTokens' array or subcollection supports multiple devices.
        // For simplicity, let's update a field for now, or check if we want multi-device.
        // The user didn't specify, but single device per user is a common MV.
        // However, users might use multiple devices.
        // Let's use a merge update to a map or array if possible, or just overwrite for now.
        // Overwriting is safest for MVP 'make it work'.

        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'appType': appType,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });

        AppLogger.logInfo('FCM Token saved for user $userId ($appType)');

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          await _firestore.collection('users').doc(userId).update({
            'fcmToken': newToken,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
          AppLogger.logInfo('FCM Token refreshed and saved for user $userId');
        });
      }
    } catch (e) {
      AppLogger.logError('Failed to save FCM token', error: e);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.logInfo('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.logError('Failed to subscribe to topic $topic', error: e);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.logInfo('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.logError('Failed to unsubscribe from topic $topic', error: e);
    }
  }
}
