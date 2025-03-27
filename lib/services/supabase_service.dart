// DEPRECATED: This service has been replaced with CloudinaryService
// Keeping this file for reference only
// Last updated: [Current Date]

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart' as io;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

// Conditional import for web
import 'web_file_handler.dart' if (dart.library.io) 'mobile_file_handler.dart';

@deprecated
class SupabaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Define storage bucket name (singular form)
  static const String _storageBucket = 'athlete-image';

  // Helper method to determine content type
  static String _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      default:
        return 'application/octet-stream';
    }
  }

  // Fetch profile image URL from Firebase
  static Future<String?> fetchProfileImage(String athleteId) async {
    try {
      final ref = _database.ref('athletes/$athleteId/profilePicture');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        return snapshot.value.toString();
      }
      return null;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  // Delete profile picture from Firebase
  static Future<void> deleteProfilePicture(String athleteId) async {
    try {
      // Remove URL from Firebase
      await _database.ref('athletes/$athleteId/profilePicture').remove();
      print('Successfully deleted profile picture');
    } catch (e) {
      print('Error deleting profile picture: $e');
      throw Exception('Failed to delete profile picture: $e');
    }
  }
}
