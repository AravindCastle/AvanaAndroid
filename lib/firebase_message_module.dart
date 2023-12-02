import 'package:avana_academy/Utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationHandler {
  void registerNotification() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    _requestPermissionsAndRegister(messaging);
    messaging.subscribeToTopic(Utils.notifyTopic).then((value) => {});
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Handle background notification here
  }

  void _requestPermissionsAndRegister(FirebaseMessaging messaging) async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Permission granted, register for notifications
      String token = await messaging.getToken();
      print('Firebase Messaging token: $token');
    } else {
      // Permission denied
      print('User declined permission for push notifications');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notification here
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap here
    });

    try {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    } catch (err) {
      print(err);
    }
  }

  static Future<void> sendPushNotification(String title, String body) async {
    final serverKey =
        "AAAASEoD0Cs:APA91bGyQ_4okzlekYjSBRahQIaNEpivPBeJERUO0cNGnuDnm_Cto-kM_4y1FQxax9RlJJlIG_xUIbIWX3-EqCSuWdnD7jzknpIx0qx0sZ1fjDK5BOEOrLrD2fWyTAKQVD-VHdAo-rAf";
    final firebaseUrl = 'https://fcm.googleapis.com/fcm/send';

    final message = {
      'notification': {
        'title': title,
        'body': body,
      },
      'to': '/topics/' +
          Utils
              .notifyTopic, // Replace with the topic name or use '/topics/token' for sending to a specific device token
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final response = await http.post(
      Uri.parse(firebaseUrl),
      headers: headers,
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      print('Push notification sent successfully!');
    } else {
      print('Failed to send push notification. Error: ${response.body}');
    }
  }
}
