import 'dart:typed_data';
import 'package:universal_io/io.dart' as io;
import 'package:path/path.dart' as path;
import 'file_handler_interface.dart';

class FileHandler implements FileHandlerInterface {
  static Future<FileResult> processFile(
    dynamic file,
    String athleteId,
    int timestamp,
  ) async {
    if (file is! io.File) {
      throw Exception('Invalid file type for mobile upload');
    }

    final fileExt = path.extension(file.path);
    final fileName = 'profile_${athleteId}_$timestamp$fileExt';
    final Uint8List fileBytes = await file.readAsBytes();

    return FileResult(
      fileName: fileName,
      fileBytes: fileBytes,
    );
  }
}
