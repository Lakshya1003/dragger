import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../config/cloudinary_config.dart';

class CloudinaryService {
  static final CloudinaryService instance = CloudinaryService._internal();
  final Dio _dio = Dio();
  final String _baseUrl =
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload';

  CloudinaryService._internal() {
    _validateConfig();
  }

  void _validateConfig() {
    if (CloudinaryConfig.cloudName.isEmpty) {
      throw Exception('Cloudinary cloud name is not configured');
    }
    if (CloudinaryConfig.uploadPreset.isEmpty) {
      throw Exception('Cloudinary upload preset is not configured');
    }
  }

  Future<String> uploadImage(dynamic file) async {
    try {
      FormData formData;

      if (kIsWeb) {
        if (file is! Uint8List) {
          throw Exception('For web uploads, file must be Uint8List');
        }
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            file,
            filename:
                'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
          'upload_preset': CloudinaryConfig.uploadPreset,
          'api_key': CloudinaryConfig.apiKey,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        });
      } else {
        if (file is! File) {
          throw Exception('For mobile uploads, file must be File');
        }
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path),
          'upload_preset': CloudinaryConfig.uploadPreset,
          'api_key': CloudinaryConfig.apiKey,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        });
      }

      final response = await _dio.post(
        _baseUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint(
            'Upload successful. Secure URL: ${response.data['secure_url']}');
        return response.data['secure_url'];
      } else {
        debugPrint('Upload failed with status code: ${response.statusCode}');
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image to Cloudinary: $e');
      rethrow;
    }
  }

  Future<String> uploadImageFromBytes(List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          Uint8List.fromList(bytes),
          filename: '${fileName}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'api_key': CloudinaryConfig.apiKey,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      final response = await _dio.post(
        _baseUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint(
            'Upload successful. Secure URL: ${response.data['secure_url']}');
        return response.data['secure_url'];
      } else {
        debugPrint('Upload failed with status code: ${response.statusCode}');
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image to Cloudinary: $e');
      rethrow;
    }
  }
}
