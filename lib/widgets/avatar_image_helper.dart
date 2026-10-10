import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider getAvatarImageProvider(String? url) {
  const fallbackUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80';
  if (url == null || url.trim().isEmpty) {
    return const NetworkImage(fallbackUrl);
  }
  final trimmed = url.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return NetworkImage(trimmed);
  }
  try {
    final file = File(trimmed);
    if (file.existsSync()) {
      return FileImage(file);
    }
  } catch (_) {}
  return NetworkImage(trimmed);
}
