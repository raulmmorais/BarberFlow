import 'package:firebase_core/firebase_core.dart';
import 'package:barberflow/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
