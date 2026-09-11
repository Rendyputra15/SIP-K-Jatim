// lib/services/file_saver_io.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

void saveAndDownloadFile(Uint8List bytes, String filename, String mimeType) {
  try {
    Directory? targetDir;

    if (Platform.isAndroid) {
      // Prioritas 1: Folder publik "Download" di memori internal HP Android
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (downloadDir.existsSync()) {
        targetDir = downloadDir;
      }
    }

    // Fallback ke direktori sistem sementara jika folder Download tidak ditemukan
    targetDir ??= Directory.systemTemp;

    final file = File('${targetDir.path}/$filename');
    file.writeAsBytesSync(bytes);
    debugPrint('File berhasil diekspor ke: ${file.path}');
  } catch (e) {
    debugPrint('Gagal menyimpan ke folder publik, mencoba fallback: $e');
    try {
      final fallbackFile = File('${Directory.systemTemp.path}/$filename');
      fallbackFile.writeAsBytesSync(bytes);
      debugPrint('File disimpan ke direktori temp: ${fallbackFile.path}');
    } catch (err) {
      debugPrint('Gagal total menyimpan file: $err');
    }
  }
}
