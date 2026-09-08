import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

ImageProvider<Object>? imageProviderFromSource(String source) {
  final dataUriMarker = RegExp(r'^data:image/(png|jpeg|jpg);base64,');
  final match = dataUriMarker.firstMatch(source);
  if (match != null) {
    final encoded = source.substring(match.end);
    try {
      return MemoryImage(base64Decode(encoded));
    } on FormatException {
      return null;
    }
  }

  if (source.startsWith('assets/')) {
    return AssetImage(source);
  }

  return null;
}

class AppImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final Widget placeholder;

  const AppImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.placeholder = const Icon(Icons.image_not_supported_outlined),
  });

  @override
  Widget build(BuildContext context) {
    final provider = imageProviderFromSource(source);
    if (provider == null) return placeholder;

    return Image(
      image: provider,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

bool isSupportedImageFile(String fileName) {
  final extension = fileName.toLowerCase().split('.').last;
  return extension == 'png' || extension == 'jpg' || extension == 'jpeg';
}

String imageDataUri(String fileName, Uint8List bytes) {
  final extension = fileName.toLowerCase().split('.').last;
  final mimeType = extension == 'png' ? 'png' : 'jpeg';
  return 'data:image/$mimeType;base64,${base64Encode(bytes)}';
}
