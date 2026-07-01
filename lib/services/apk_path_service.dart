import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
class ApkPathService {
  static const _channel = MethodChannel('com.example.file_share_app/apk_path');
  static Future<String?> getApkPath(String packageName) async {
    try{
      final String? path = await _channel.invokeMethod('getApkPath', {
      'packageName': packageName,
    });
    return path;
    } on PlatformException catch (e) {
    debugPrint('Failed to get APK path: ${e.message}');
    return null;
  }
  }
}
