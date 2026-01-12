import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

class NotificationSenderService {
  // TODO: Replace with your actual Firebase Cloud Messaging Server Key
  // Go to Firebase Console > Project Settings > Cloud Messaging > Cloud Messaging API (Legacy)
  // If it's disabled, enable it via the 3-dot menu or Google Cloud Console.
  static const String _serverKey = 'REPLACE_WITH_YOUR_SERVER_KEY';
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  Future<void> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': '/topics/$topic',
          'notification': {'title': title, 'body': body, 'sound': 'default'},
          'data': {...?data, 'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.logInfo('Notification sent to topic: $topic');
      } else {
        AppLogger.logError(
          'Failed to send notification. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      AppLogger.logError('Error sending notification to topic', error: e);
    }
  }

  Future<void> sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {'title': title, 'body': body, 'sound': 'default'},
          'data': {...?data, 'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.logInfo('Notification sent to token');
      } else {
        AppLogger.logError(
          'Failed to send notification. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      AppLogger.logError('Error sending notification to token', error: e);
    }
  }
}
