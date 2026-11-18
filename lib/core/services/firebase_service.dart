import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static FirebaseFirestore? get firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      
      final db = firestore;
      if (db != null) {
        db.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
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
