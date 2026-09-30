import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static Future<int> getCacheSizeInBytes() async {
    final cacheDir = await getTemporaryDirectory();
    int totalSize = 0;
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
        try {
          totalSize += await entity.length();
        }
        catch (_) {}
      }
    }
  }
  return totalSize;
}

static Future<void> clearCache() async {
  final cacheDir = await getTemporaryDirectory();
  if (await cacheDir.exists()) {
    try {
      await for (final entity in cacheDir.list()) {
        await entity.delete(recursive: true);
      }
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
}