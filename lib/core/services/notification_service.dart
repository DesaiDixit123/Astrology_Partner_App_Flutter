import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../network/api_service.dart';
import '../constants/api_constants.dart';
import '../../../config/routes/app_routes.dart';
import '../../features/calls/presentation/controllers/partner_call_controller.dart';
import '../../features/chat/presentation/controllers/chat_request_controller.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('Partner granted permission: ${settings.authorizationStatus}');
    }

    // 2. Setup Local Notifications
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
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(details.payload!);
            handleNotificationNavigation(data);
          } catch (e) {
            if (kDebugMode) print('Error parsing notification payload: $e');
          }
        }
      },
    );

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // 4. Handle Background Message Taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Partner onMessageOpenedApp: ${message.data}');
      }
      handleNotificationNavigation(message.data);
    });

    // 5. Handle Terminated App Launch from Notification
    final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('Partner launched from terminated notification: ${initialMessage.data}');
      }
      // Wait slightly for GetX navigation stack to be ready
      Future.delayed(const Duration(milliseconds: 600), () {
        handleNotificationNavigation(initialMessage.data);
      });
    }

    // 6. Get and Sync Token
    await syncToken();

    // 7. Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      _updateTokenInBackend(newToken);
    });
  }

  static void handleNotificationNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    if (kDebugMode) print('Navigating from notification data: $data');

    // Ensure core controllers exist so navigation never fails
    if (!Get.isRegistered<DashboardController>()) {
      Get.put<DashboardController>(DashboardController(), permanent: true);
    }
    if (!Get.isRegistered<ChatRequestController>()) {
      Get.put<ChatRequestController>(ChatRequestController(), permanent: true);
    }

    final type = data['type']?.toString().toLowerCase() ?? '';
    final sessionId = data['session_id']?.toString() ?? data['sessionId']?.toString() ?? '';
    final customerId = data['customer_id']?.toString() ?? '';
    final customerName = data['customer_name']?.toString() ?? 'User';
    final customerPic = data['customer_pic']?.toString() ?? data['profile_pic']?.toString() ?? '';
    final pricePerMin = num.tryParse(data['price_per_minute']?.toString() ?? '0') ?? 0;

    if (type == 'chat' || type == 'new_chat_session') {
      // Never interrupt an active chat or call
      if (Get.currentRoute == AppRoutes.partnerChat || Get.currentRoute == AppRoutes.voiceCall || Get.currentRoute == AppRoutes.videoCall) {
        return;
      }

      final requestData = {
        'session': {
          '_id': sessionId,
          'price_per_minute': pricePerMin,
          'status': 'initiated',
        },
        'customer': {
          '_id': customerId,
          'name': customerName,
          'profile_pic': customerPic,
        },
        'price_per_minute': pricePerMin,
      };

      if (!Get.isRegistered<ChatRequestController>()) {
        Get.put<ChatRequestController>(ChatRequestController(), permanent: true);
      }
      Get.find<ChatRequestController>().setIncomingRequest(requestData);

      if (!Get.isRegistered<DashboardController>()) {
        Get.put<DashboardController>(DashboardController(), permanent: true);
      }
      final dashboard = Get.find<DashboardController>();
      dashboard.currentIndex.value = 1;

      if (Get.currentRoute != AppRoutes.dashboard) {
        Get.offAllNamed(AppRoutes.dashboard);
        dashboard.currentIndex.value = 1;
      }
    } else if (type == 'call' || type == 'video_call') {
      final isVideo = type == 'video_call';
      final callData = {
        'session_id': sessionId,
        'channel': data['channel'] ?? '',
        'agora_token': data['agora_token'] ?? '',
        'agora_app_id': data['agora_app_id'] ?? '',
        'price_per_minute': pricePerMin,
        'customer': {
          '_id': customerId,
          'name': customerName,
          'profile_pic': customerPic,
        },
      };

      if (Get.isRegistered<PartnerCallController>()) {
        PartnerCallController.to.handleIncomingFromNotification(callData, isVideo: isVideo);
      } else {
        final ctrl = Get.put<PartnerCallController>(PartnerCallController());
        ctrl.handleIncomingFromNotification(callData, isVideo: isVideo);
      }
    } else if (type == 'puja' || type == 'puja_order') {
      Get.toNamed(AppRoutes.pujaOrders);
    } else if (type == 'review') {
      Get.toNamed(AppRoutes.reviews);
    }
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
      payload: jsonEncode(message.data),
    );
  }
}
