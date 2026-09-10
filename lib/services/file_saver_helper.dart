// lib/services/file_saver_helper.dart
// Conditional export agar dart:html hanya di-import pada platform web
export 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';
