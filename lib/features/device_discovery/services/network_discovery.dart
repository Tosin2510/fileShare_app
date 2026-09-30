import 'dart:async';
import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:file_share_app/constants/app_constant.dart';
import 'package:flutter/material.dart';

enum DiscoveryState {idle, starting, stopping, scanning}
class NetworkDiscovery {
  BonsoirDiscovery? discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? discoverySubscription;
  DiscoveryState _state = DiscoveryState.idle;
  final List<BonsoirService> discoveredDevices = [];
  List<String> selfIps = [];
  Timer? livenessCheckTimer; 

  final StreamController<List<BonsoirService>> deviceController = 
  StreamController<List<BonsoirService>>.broadcast();
  Stream <List<BonsoirService>> get deviceStream => deviceController.stream;
  bool get isScanning => _state == DiscoveryState.scanning;
  DiscoveryState get state => _state;

  Future<void> startScanning() async {
    if(_state!= DiscoveryState.idle) return;
    _state = DiscoveryState.starting;
    selfIps = await getAllLocalIps();
      discoveredDevices.clear();
      if (!deviceController.isClosed) {
        deviceController.add([]);
      }
      try {
        discovery = BonsoirDiscovery(type: AppConstant.serviceType);
        await discovery!.initialize();
        discoverySubscription = discovery!.eventStream?.listen((event) {
          handleDiscoveryEvent(event);
        });
        await discovery!.start();
        _state = DiscoveryState.scanning;
        startLivenessCheck();
        debugPrint('Local Network scanning service active');
      } catch(e) {
        debugPrint('Failure initializing discovery: $e');
        await discoverySubscription?.cancel();
        discoverySubscription = null;
        discovery = null;
        _state = DiscoveryState.idle;
      }
  }
  void startLivenessCheck() {
    livenessCheckTimer?.cancel();
    livenessCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_state != DiscoveryState.scanning) return;
      final snapshot = List<BonsoirService>.from(discoveredDevices);
      bool changed = false;
        for (final device in snapshot) {
          final alive = await isReachable(device.hostAddress, device.port);
          if (_state != DiscoveryState.scanning) return;
          if (!alive) {
            discoveredDevices.removeWhere((d) => d.name == device.name);
            debugPrint('Removed unreachable device: ${device.name}');
            changed = true;
        }
    }
    if (changed && !deviceController.isClosed) {
      deviceController.add(List.from(discoveredDevices));
    }
  });
  }

  Future<bool> isReachable(String? ip, int? port) async {
    if (ip == null || port == null) return false;
    try {
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 3)); 
      socket.destroy();
      return true;
    } catch(e) {
      return false;
    }
  } 

  Future<List<String>> getAllLocalIps() async {
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
      livenessCheckTimer?.cancel();
      livenessCheckTimer = null; 
      try {
        await discoverySubscription?.cancel();
        discoverySubscription = null;
        await discovery?.stop();
      } catch(e) {
        debugPrint('Error stopping discovery service $e');
      } finally {
        discovery = null;
        _state = DiscoveryState.idle;
        debugPrint('Local network scanning has stopped cleanly');
      }
  }

  void handleDiscoveryEvent(BonsoirDiscoveryEvent event) {
    if(state != DiscoveryState.scanning) return;
    switch(event) {
      case BonsoirDiscoveryServiceFoundEvent():
      if(discovery == null) return;
       event.service.resolve(discovery!.serviceResolver);
       break;
      case BonsoirDiscoveryServiceResolvedEvent():
      final resolvedIp = event.service.hostAddress;
      if (resolvedIp != null && selfIps.contains(resolvedIp)) return;
       
       discoveredDevices.removeWhere((device) => device.name == event.service.name);
       discoveredDevices.add(event.service);
       if (!deviceController.isClosed) {
        deviceController.add(List.from(discoveredDevices));
       }
       debugPrint('Service resolved: ${event.service.name} at ${event.service.port} '); break;
      case BonsoirDiscoveryServiceLostEvent(): 
       discoveredDevices.removeWhere((device) => device.name == event.service.name);
       if (!deviceController.isClosed) {
          deviceController.add(List.from(discoveredDevices));
       }
       debugPrint('Service Lost: ${event.service.name}');
       break;
      default:
       break;
    }
  }
  Future<void> dispose() async{
    await stopScanning();
    await deviceController.close();
    debugPrint('Network discovery engine tracking resources successfully released');
  }
}