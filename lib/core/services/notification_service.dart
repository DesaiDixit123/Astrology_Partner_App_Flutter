import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../network/api_service.dart';
import '../constants/api_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Note: Firebase MUST be initialized before calling this method.
    // This is already done in main.dart.

    // 2. Request Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('Partner granted permission: ${settings.authorizationStatus}');
    }

    // 3. Setup Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        _showLocalNotification(message);
      }
      
      // Handle call type notifications specifically if needed
      final type = message.data['type'];
      if (type == 'call' || type == 'video_call') {
        // The socket listener in PartnerCallController should also pick this up if online.
        // If we want to force open the overlay from FCM:
        // print('Call notification received via FCM: ${message.data}');
      }
    });

    // 5. Handle Background/Terminated Message Taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
    });

    // 6. Get and Sync Token
    await syncToken();

    // 7. Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      _updateTokenInBackend(newToken);
    });
  }

  Future<void> syncToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _fcm.getAPNSToken();
        }
      }

      String? token = await _fcm.getToken();
      if (token != null) {
        if (kDebugMode) {
          print("Partner FCM Token: $token");
        }
        await _updateTokenInBackend(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting FCM token: $e");
      }
    }
  }

  Future<void> _updateTokenInBackend(String token) async {
    try {
      // Use partner profile update endpoint
      await ApiService.instance.put(
        ApiConstants.profile,
        data: {'fcm_token': token},
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error syncing Partner FCM token: $e");
      }
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'vedikvani_partner_channel', // id
      'Vedikvani Partner Notifications', // title
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }
}
