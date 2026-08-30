import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceNameService{
  static const _suffixKey = 'device_suffix';
  static const _customDeviceNameKey = 'custom_device_name';

// This part is responsible for getting the name of the device.
  static Future<String> getDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    final customName = prefs.getString(_customDeviceNameKey);
    if (customName != null && customName.trim().isNotEmpty) return customName;
    final baseName = await _getBaseName();
    final suffix = await _getOrCreateSuffix();
    return '$baseName ($suffix)';
  }

// This basically allows users to set their preferred name for their device.
  static Future<void> setCustomDeviceName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null || name.trim().isEmpty) {
      await prefs.remove(_customDeviceNameKey);
    } else {
      await prefs.setString(_customDeviceNameKey, name.trim());
    }
  }

// The custom device name set by the user is got here.
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

  // I actually added this function so that no two device with the same device name can be seen the same way in the device list.
  // If two or more device have the same name, random suffix is added to the end of the device name.
  static Future<String> _getOrCreateSuffix() async {
    final prefs = await SharedPreferences.getInstance();
    String? suffix = prefs.getString(_suffixKey);
    if (suffix == null) {
      suffix = _generateSuffix();
      await prefs.setString(_suffixKey, suffix);
    }
    return suffix;
  }
  // The suffix is generated from this place...
  static String _generateSuffix() {
    const character = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(4, (_) => character[rand.nextInt(character.length)]).join();
  }
}