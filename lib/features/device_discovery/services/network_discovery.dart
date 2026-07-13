import 'dart:async';
import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:file_share_app/constants/app_constant.dart';
import 'package:flutter/material.dart';

enum DiscoveryState {idle, starting, stopping, scanning}
class NetworkDiscovery {
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySubscription;
  DiscoveryState _state = DiscoveryState.idle;
  final List<BonsoirService> discoveredDevices = [];
  List<String> _selfIps = [];
  Timer? _livenessCheckTimer; 

  final StreamController<List<BonsoirService>> _deviceController = 
  StreamController<List<BonsoirService>>.broadcast();
  Stream <List<BonsoirService>> get deviceStream => _deviceController.stream;
  bool get isScanning => _state == DiscoveryState.scanning;
  DiscoveryState get state => _state;

  Future<void> startScanning() async {
    if(_state!= DiscoveryState.idle) return;
    _state = DiscoveryState.starting;
    _selfIps = await _getAllLocalIps();
    debugPrint('Self Ips detected: $_selfIps');
      discoveredDevices.clear();
      if (!_deviceController.isClosed) {
        _deviceController.add([]);
      }
      try {
        _discovery = BonsoirDiscovery(type: AppConstant.serviceType);
        await _discovery!.initialize();
        _discoverySubscription = _discovery!.eventStream?.listen((event) {
          handleDiscoveryEvent(event);
        });
        await _discovery!.start();
        _state = DiscoveryState.scanning;
        _startLivenessCheck();
        debugPrint('Local Network scanning service active');
      } catch(e) {
        debugPrint('Failure initializing discovery: $e');
        await _discoverySubscription?.cancel();
        _discoverySubscription = null;
        _discovery = null;
        _state = DiscoveryState.idle;
      }
  }
  void _startLivenessCheck() {
    _livenessCheckTimer?.cancel();
    _livenessCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_state != DiscoveryState.scanning) return;
      final snapshot = List<BonsoirService>.from(discoveredDevices);
      bool changed = false;
        for (final device in snapshot) {
          final alive = await _isReachable(device.hostAddress, device.port);
          if (_state != DiscoveryState.scanning) return;
          if (!alive) {
            discoveredDevices.removeWhere((d) => d.name == device.name);
            debugPrint('Removed unreachable device: ${device.name}');
            changed = true;
        }
    }
    if (changed && !_deviceController.isClosed) {
      _deviceController.add(List.from(discoveredDevices));
    }
  });
  }

  Future<bool> _isReachable(String? ip, int? port) async {
    if (ip == null || port == null) return false;
    try {
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 3)); 
      socket.destroy();
      return true;
    } catch(e) {
      return false;
    }
  } 

  Future<List<String>> _getAllLocalIps() async {
    final ips = <String> [];
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          ips.add(addr.address);
        }
      }
    } catch (e) {
      debugPrint('Failed to get local IPs: $e');
    }
    return ips;
  }
  Future<void> stopScanning() async {
    if (_state == DiscoveryState.idle || _state == DiscoveryState.stopping) return; 
      _state = DiscoveryState.stopping;
      _livenessCheckTimer?.cancel();
      _livenessCheckTimer = null; 
      try {
        await _discoverySubscription?.cancel();
        _discoverySubscription = null;
        await _discovery?.stop();
      } catch(e) {
        debugPrint('Error stopping discovery service $e');
      } finally {
        _discovery = null;
        _state = DiscoveryState.idle;
        debugPrint('Local network scanning has stopped cleanly');
      }
  }

  void handleDiscoveryEvent(BonsoirDiscoveryEvent event) {
    if(state != DiscoveryState.scanning) return;
    switch(event) {
      case BonsoirDiscoveryServiceFoundEvent():
      if(_discovery == null) return;
       debugPrint('Service found: ${event.service.name}. Resolving...');
       //Forces Bonsoir to fetch the IP address and Port, should be called when the user wants to connect to this service.
       event.service.resolve(_discovery!.serviceResolver);
       break;
      case BonsoirDiscoveryServiceResolvedEvent():
      final resolvedIp = event.service.hostAddress;
      debugPrint('==SELF CHECK === resolvedIp: $resolvedIp | selfIps: $_selfIps');
      if (resolvedIp != null && _selfIps.contains(resolvedIp)) return;
       // The service is fully resolved with host and port, ready for connection!
       // Clear any old unresolved copies of this device name before adding the fresh one
       discoveredDevices.removeWhere((device) => device.name == event.service.name);
       discoveredDevices.add(event.service);
       if (!_deviceController.isClosed) {
        _deviceController.add(List.from(discoveredDevices));
       }
       debugPrint('Service resolved: ${event.service.name} at ${event.service.port} '); break;
      case BonsoirDiscoveryServiceLostEvent(): 
       discoveredDevices.removeWhere((device) => device.name == event.service.name);
       if (!_deviceController.isClosed) {
         _deviceController.add(List.from(discoveredDevices));
       }
       debugPrint('Service Lost: ${event.service.name}');
       break;
      default:
       break;
    }
  }
  Future<void> dispose() async{
    await stopScanning();
    await _deviceController.close();
    debugPrint('Network discovery engine tracking resources successfully released');
  }
}