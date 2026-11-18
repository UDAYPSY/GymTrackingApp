import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static FirebaseFirestore get firestore => _firestore;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      
      // Enable Firestore offline caching
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      if (kDebugMode) {
        print("Firebase & Firestore Offline Persistence initialized successfully.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Firebase initialization warning (using local/fallback mode): $e");
      }
    }
  }
}
