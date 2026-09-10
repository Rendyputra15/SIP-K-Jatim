// lib/services/file_saver_stub.dart
import 'dart:typed_data';

void saveAndDownloadFile(Uint8List bytes, String filename, String mimeType) {
  throw UnsupportedError('Platform not supported for file download');
}
