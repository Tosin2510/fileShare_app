import 'package:bonsoir/bonsoir.dart';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:file_share_app/user_device_name.dart';

class NetworkService {
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;

  static const int defaultPort = 52525; 
  int _currentPort = defaultPort;

  // Getter so other parts of your app (like the HTTP Server) know which port was actually chosen.
  int get currentPort => _currentPort;

  final String type = '_tosinfileshare._tcp';

  Future<void> startBroadcasting() async {
    try {
      // 1. Try preferred port first
      bool isDefaultPortFree = await _isPortAvailable(defaultPort);
      
      if (isDefaultPortFree) {
        _currentPort = defaultPort;
      } else {
        // 2. Fallback to a random available port
        _currentPort = await _findRandomPort();
      }

      String displayName = await getDeviceDisplayName();
      
      BonsoirService service = BonsoirService(
        name: displayName,
        type: type,
        port: _currentPort,
      );

      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.start();
      
      dev.log("Broadcasting as $displayName on port $_currentPort", name: "NetworkService");
    } catch (e) {
      dev.log("Error starting broadcast", name: "NetworkService", error: e);
    }
  }
  
  Future<void> stopBroadcasting() async {
    await _broadcast?.stop();
    _broadcast = null;
    dev.log("Broadcasting stopped", name: "NetworkService");
  }

  // Private helper to check availability
  Future<bool> _isPortAvailable(int port) async {
    try {
      final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      await server.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Private helper to scout for ANY port
  Future<int> _findRandomPort() async {
    ServerSocket server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    int port = server.port;
    await server.close();
    return port;
  }
}