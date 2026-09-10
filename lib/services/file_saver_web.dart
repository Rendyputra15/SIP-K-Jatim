// lib/services/file_saver_web.dart
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

void saveAndDownloadFile(Uint8List bytes, String filename, String mimeType) {
  final base64Data = base64Encode(bytes);
  final dataUri = 'data:$mimeType;base64,$base64Data';
  final anchor = html.AnchorElement(href: dataUri)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
}
