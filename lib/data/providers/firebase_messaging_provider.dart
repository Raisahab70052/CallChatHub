import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/call_controller.dart';
import '../../viewmodels/timer_controller.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  }
}

class FirebaseMessagingProvider extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  final RxString fcmToken = ''.obs;
  final Rx<RemoteMessage?> lastMessage = Rx<RemoteMessage?>(null);

  Future<FirebaseMessagingProvider> init() async {
    // Request notification permissions
    await requestPermission();
    
    // Get FCM token
    await getToken();
    
    // Listen to token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      fcmToken.value = newToken;
      if (kDebugMode) {
        print('FCM Token refreshed: $newToken');
      }
    });

    // Configure foreground notification presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle notification tap when app was fully terminated.
    // Delay 2 s so the app is fully mounted before navigation.
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Future<void>.delayed(
          const Duration(seconds: 2),
          () => _handleMessageOpenedApp(message),
        );
      }
    });

    if (kDebugMode) {
      print('FirebaseMessagingProvider initialized');
    }

    return this;
  }

  Future<void> requestPermission() async {
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) {
        print('User denied notification permissions');
      }
    }
  }

  Future<void> getToken() async {
    try {
      final String? token = await _messaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        if (kDebugMode) {
          print('FCM Token: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    lastMessage.value = message;
    if (kDebugMode) {
      print('Foreground FCM: ${message.data}');
    }
    _handleNotificationData(message.data);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    lastMessage.value = message;
    if (kDebugMode) {
      print('FCM opened app: ${message.data}');
    }
    _handleNotificationData(message.data);
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    if (data['type'] != 'incoming_call') return;

    final String channelId = data['channelId'] as String? ?? '';
    if (channelId.isEmpty) return;

    final String callerName = data['callerName'] as String? ?? 'Unknown';
    final String callerEmail = data['callerEmail'] as String? ?? '';
    final String callerId = data['callerId'] as String? ?? '';

    final UserModel caller = UserModel(
      id: callerId,
      name: callerName,
      email: callerEmail,
      status: 'calling',
      isOnline: true,
    );

    // Avoid pushing duplicate screens.
    if (Get.currentRoute == AppRoutes.incomingCall) return;

    // Force-delete any stale CallController so onInit() always runs fresh
    // with the new caller/channelId arguments.
    Get.delete<CallController>(force: true);
    Get.delete<TimerController>(force: true);

    Get.toNamed(
      AppRoutes.incomingCall,
      arguments: <String, dynamic>{
        'user': caller,
        'channelId': channelId,
        'isCaller': false,
      },
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }

  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      fcmToken.value = '';
      if (kDebugMode) {
        print('FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting FCM token: $e');
      }
    }
  }
}
