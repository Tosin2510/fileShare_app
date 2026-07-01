import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
class ApkPathService {
  // Creates the flutter side of the communication.
  static const _channel = MethodChannel('com.example.file_share_app/apk_path');
  static Future<String?> getApkPath(String packageName) async {
    try{
      // This sends a message to the native side.
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
