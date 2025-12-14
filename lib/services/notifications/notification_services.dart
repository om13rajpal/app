import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  const NotificationService._();

  static FlutterLocalNotificationsPlugin? _localNotificationsPlugin;
  static final Random _random = Random();

  static void initialize(
      {DidReceiveNotificationResponseCallback?
          onDidReceiveNotificationResponse}) {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings iosInitialize =
        const DarwinInitializationSettings();

    InitializationSettings initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iosInitialize);

    _localNotificationsPlugin?.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    _localNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      return await _localNotificationsPlugin
              ?.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    } else {
      return await _localNotificationsPlugin
              ?.resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
  }

  static Future<void> showNotification({
    required String? title,
    required String? body,
    String? payload,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      importance: _channel.importance,
      priority: Priority.max,
      playSound: true,
      fullScreenIntent: true,
    );

    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    return await _localNotificationsPlugin?.show(
      _random.nextInt(9999),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'default_notification_channel_id',
    'project_name', //Add permission according it in manifest
    importance: Importance.max,
    enableLights: true,
  );
}
