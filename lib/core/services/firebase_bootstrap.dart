import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<void> initializeIfConfigured() async {
    const useFirebase = String.fromEnvironment('USE_FIREBASE') == 'true';
    if (!useFirebase) {
      return;
    }
    await Firebase.initializeApp();
  }
}
