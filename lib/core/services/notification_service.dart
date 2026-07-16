import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  const NotificationService();

  Future<String?> preparePushNotifications() async {
    const useFirebase = String.fromEnvironment('USE_FIREBASE') == 'true';
    if (!useFirebase) {
      return null;
    }
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    return messaging.getToken();
  }
}
