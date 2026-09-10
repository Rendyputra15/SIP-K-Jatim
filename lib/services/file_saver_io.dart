// lib/services/file_saver_io.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

void saveAndDownloadFile(Uint8List bytes, String filename, String mimeType) {
  try {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$filename');
    file.writeAsBytesSync(bytes);
    debugPrint('File berhasil diekspor ke: ${file.path}');
  } catch (e) {
    debugPrint('Gagal menyimpan file di perangkat: $e');
  }
}
