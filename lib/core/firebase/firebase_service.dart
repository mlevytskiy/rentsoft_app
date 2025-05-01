import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_config.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static bool _initialized = false;
  static FirebaseFirestore? _firestore;

  /// Initialize Firebase for the application
  Future<void> initialize() async {
    if (!_initialized) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: firebaseConfig['apiKey'] as String,
          authDomain: firebaseConfig['authDomain'] as String,
          projectId: firebaseConfig['projectId'] as String,
          storageBucket: firebaseConfig['storageBucket'] as String,
          messagingSenderId: firebaseConfig['messagingSenderId'] as String,
          appId: firebaseConfig['appId'] as String,
        ),
      );
      _firestore = FirebaseFirestore.instance;
      _initialized = true;
    }
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore {
    if (!_initialized) {
      throw Exception('Firebase has not been initialized. Call initialize() first.');
    }
    return _firestore!;
  }
}
