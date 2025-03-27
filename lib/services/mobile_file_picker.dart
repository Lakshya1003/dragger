import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FilePicker {
  static Future<dynamic> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
