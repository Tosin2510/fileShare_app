import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceNameService{
  static const _suffixKey = 'device_suffix';
  static const _customDeviceNameKey = 'custom_device_name';

  static Future<String> getDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    final customName = prefs.getString(_customDeviceNameKey);
    if (customName != null && customName.trim().isNotEmpty) return customName;
    final baseName = await _getBaseName();
    final suffix = await _getOrCreateSuffix();
    return '$baseName ($suffix)';
  }

  static Future<void> setCustomDeviceName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null || name.trim().isEmpty) {
      await prefs.remove(_customDeviceNameKey);
    } else {
      await prefs.setString(_customDeviceNameKey, name.trim());
    }
  }

  static Future<String?> getCustomDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customDeviceNameKey);
  }
  static Future<String> _getBaseName() async {
    final deviceInfo = DeviceInfoPlugin();
    try{
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return info.model;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.name;
      }
    } catch(e) {
      // Fall back option
    }
    return 'Unknown Device';
  }
  static Future<String> _getOrCreateSuffix() async {
    final prefs = await SharedPreferences.getInstance();
    String? suffix = prefs.getString(_suffixKey);
    if (suffix == null) {
      suffix = _generateSuffix();
      await prefs.setString(_suffixKey, suffix);
    }
    return suffix;
  }
  static String _generateSuffix() {
    const character = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(4, (_) => character[rand.nextInt(character.length)]).join();
  }
}