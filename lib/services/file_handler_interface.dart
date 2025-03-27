import 'dart:typed_data';

class FileResult {
  final String fileName;
  final Uint8List fileBytes;

  FileResult({
    required this.fileName,
    required this.fileBytes,
  });
}

abstract class FileHandlerInterface {
  static Future<FileResult> processFile(
    dynamic file,
    String athleteId,
    int timestamp,
  ) async {
    throw UnimplementedError();
  }
}
