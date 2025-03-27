import 'dart:html' as html;
import 'dart:async';

class FilePicker {
  static Future<dynamic> pickImage() async {
    final completer = Completer<html.File?>();

    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();

    input.onChange.listen((event) {
      final file = input.files?.first;
      completer.complete(file);
    });

    input.onAbort.listen((event) {
      completer.complete(null);
    });

    return completer.future;
  }
}
