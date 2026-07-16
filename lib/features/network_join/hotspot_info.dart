import 'dart:convert';

class HotspotInfo{
  final String ssid; // To access the current network name
  final String password;
  final String deviceName;
  HotspotInfo({
    required this.ssid,
    required this.password,
    required this.deviceName,
  });
  String toJsonString() => jsonEncode({
    'ssid': ssid,
    'password': password,
    'deviceName': deviceName,
  });
  factory HotspotInfo.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return HotspotInfo(
      ssid: map['ssid'] as String,
      password: map['password'] as String,
      deviceName: map['deviceName'] as String,
    );
  }
}