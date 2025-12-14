import 'package:firebase_messaging/firebase_messaging.dart';

typedef RemoteMessageHandler = void Function(RemoteMessage message);

abstract class FcmMessagingHandler {
  void getInitialMessage();

  void onMessage();

  void onMessageOpenedApp();
}

class FcmService {
  const FcmService._();

  static FcmService get instance => const FcmService._();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      return null;
    }
  }

  static Future<NotificationSettings> requestPermission() async {
    _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    return await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void getInitialMessage(RemoteMessageHandler handler) {
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        handler(message);
      }
    });
  }

  void onMessage(RemoteMessageHandler handler) {
    FirebaseMessaging.onMessage.listen(handler, cancelOnError: true);
  }

  void onMessageOpenedApp(RemoteMessageHandler handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler, cancelOnError: true);
  }

  static void onBackgroundMessage(BackgroundMessageHandler handler) {
    FirebaseMessaging.onBackgroundMessage(handler);
  }

  static Future<void> deleteToken() {
    return _firebaseMessaging.deleteToken();
  }
}
