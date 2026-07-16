import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
class HotspotService {
  // This attempts to read or get the ssid and password of the device's hotspot
  // It only works on android...
  // Also, it happens on the receiver's end only.
  static Future<HotspotDetails?> getCurrentHotspotDetails() async {
    try{
      final ssid = await WiFiForIoTPlugin.getWiFiAPSSID();
      final password = await WiFiForIoTPlugin.getWiFiAPPreSharedKey();
      debugPrint('=== HOTSPOT CHECK === ssid: $ssid | password: $password');

      if (ssid == null || password == null) return null;
      return HotspotDetails(ssid: ssid, password: password);
    } catch (e) {
      debugPrint('=== HOTSPOT CHECK === Exception: $e');
      return null;
    }
  }
}
class HotspotDetails {
  final String ssid;
  final String password;
  HotspotDetails({required this.ssid, required this.password});
}