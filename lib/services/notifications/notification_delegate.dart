import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aiSeaSafe/utils/helper/log_helper.dart';

import '../../utils/constants/global_variable.dart';
import 'fcm_services.dart';
import 'notification_services.dart';

class NotificationDelegate
    with WidgetsBindingObserver
    implements FcmMessagingHandler {
  final FcmService _fcmService;

  NotificationDelegate._() : _fcmService = FcmService.instance;

  factory NotificationDelegate.initialize() {
    NotificationDelegate instance = NotificationDelegate._();
    NotificationService.requestPermission();
    FcmService.requestPermission();

    instance.onMessage();
    instance.getInitialMessage();
    instance.onMessageOpenedApp();

    NotificationService.initialize(
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          try {
            // final firstDecode = jsonDecode(response.payload ?? '');
            // final rowData = jsonDecode(firstDecode);

            // ChatNotificationModel data =
            //     ChatNotificationModel.fromJson(rowData);
            // instance._handleNextAction(data.metaData?.notificationType ?? '');
          } catch (e) {
            LoggerHelper.logError('Local notification payload parse error', e);
          }
        }
      },
    );

    return instance;
  }

  @override
  void onMessageOpenedApp() {
    _fcmService.onMessageOpenedApp((message) {
      try {
        LoggerHelper.logInfo('Callback: onMessageOpenedApp');
        final rawPayload = message.data['data'];
        decodeAndHandle(rawPayload);
      } catch (e) {
        LoggerHelper.logError('Error in onMessageOpenedApp', e);
      }
    });
  }

  @override
  void getInitialMessage() {
    _fcmService.getInitialMessage((message) {
      try {
        LoggerHelper.logInfo('Callback: getInitialMessage');
        final rawPayload = message.data['data'];
        decodeAndHandle(rawPayload);
      } catch (e) {
        LoggerHelper.logError('Error in getInitialMessage', e);
      }
    });
  }

  void decodeAndHandle(String? payload) {
    try {
      // final firstDecode = jsonDecode(payload ?? '');
      // final rowData = jsonDecode(firstDecode);
      // ChatNotificationModel data = ChatNotificationModel.fromJson(rowData);
      // _handleNextAction(data.metaData?.notificationType ?? '');
    } catch (e) {
      LoggerHelper.logError('Decode & Handle error', e);
    }
  }

  @override
  void onMessage() {
    _fcmService.onMessage((message) async {
      if (message.notification?.title != null) {
        if (Platform.isAndroid) {
          await NotificationService.showNotification(
            title: message.notification?.title ?? '',
            body: message.notification?.body ?? '',
            payload: message.data['data'], // Include payload for local tap
          );
        }
      }
    });
  }

  void handleNextAction(String notificationType) async {
    BuildContext? context = apNavigatorKey.currentContext;
    if (context == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // // // NotificationModel data = NotificationModel.fromJson(rawData);
        // if (notificationType == 'chat' &&
        //     (preferences.roomId != null ||
        //         (preferences.roomId?.isNotEmpty ?? false))) {
        //   Navigator.of(context).pushNamed(AppRoutes.chat, arguments: {
        //     'id': preferences.roomId,
        //   });
        // }
      } catch (e) {
        LoggerHelper.logError('Error in _handleNextAction', e);
      }
    });
  }
}
