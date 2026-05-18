import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

Future<String> getDeviceDisplayName() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Check Preferences first
    String? customName = prefs.getString('user_device_name');
    if (customName != null && customName.isNotEmpty) return customName;

    // 2. Fallback to Device Info
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String clean(String name) {
      return name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    }
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return clean(androidInfo.model);
    } 
    
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return clean(iosInfo.name);
    }

    // 3. Handle Desktop/Linux/Windows
    return clean("User-${Platform.operatingSystem}");

  } catch (e) {
    // If anything goes wrong, return a generic name instead of crashing
    return "Guest Device";
  }
}