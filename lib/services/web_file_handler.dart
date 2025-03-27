import 'dart:html' as html;
import 'dart:typed_data';
import 'file_handler_interface.dart';

class FileHandler implements FileHandlerInterface {
  static Future<FileResult> processFile(
    dynamic file,
    String athleteId,
    int timestamp,
  ) async {
    if (file is! html.File) {
      throw Exception('Invalid file type for web upload');
    }

    final fileName = 'profile_${athleteId}_$timestamp.jpg';

    // Convert web File to Uint8List
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    final Uint8List fileBytes = Uint8List.fromList(reader.result as List<int>);

    return FileResult(
      fileName: fileName,
      fileBytes: fileBytes,
    );
  }
}
