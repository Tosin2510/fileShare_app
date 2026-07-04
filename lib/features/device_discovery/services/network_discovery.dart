import 'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:file_share_app/constants/app_constant.dart';
import 'package:flutter/material.dart';

enum DiscoveryState {idle, starting, stopping, scanning}
class NetworkDiscovery {
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySubscription;
  DiscoveryState _state = DiscoveryState.idle;
  final List<BonsoirService> discoveredDevices = [];
  final StreamController<List<BonsoirService>> _deviceController = 
  StreamController<List<BonsoirService>>.broadcast();
  Stream <List<BonsoirService>> get deviceStream => _deviceController.stream;
  bool get isScanning => _state == DiscoveryState.scanning;
  DiscoveryState get state => _state;

  Future<void> startScanning() async {
    if(_state!= DiscoveryState.idle) return;
    _state = DiscoveryState.starting;
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
        debugPrint('Local Network scanning service active');
      } catch(e) {
        debugPrint('Failure initializing discovery: $e');
        await _discoverySubscription?.cancel();
        _discoverySubscription = null;
        _discovery = null;
        _state = DiscoveryState.idle;
      }
  }
  Future<void> stopScanning() async {
    if (_state == DiscoveryState.idle || _state == DiscoveryState.stopping) return; 
      _state = DiscoveryState.stopping;
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
       // The service is fully resolved with host and port, ready for connection!
       // Clear any old unresolved copies of this device name before adding the fresh one
       discoveredDevices.removeWhere((device) => device.name == event.service.name);
       discoveredDevices.add(event.service);
       _deviceController.add(List.from(discoveredDevices));
       debugPrint('Service resolved: ${event.service.name} at ${event.service.port} '); break;
      case BonsoirDiscoveryServiceLostEvent(): 
       discoveredDevices.removeWhere((device) => device.name == event.service.name);
       _deviceController.add(List.from(discoveredDevices));
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