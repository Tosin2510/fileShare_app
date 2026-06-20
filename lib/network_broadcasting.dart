import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'dart:async';

enum BroadcastState {idle, starting, broadcasting, stopping}
class NetworkBroadcasting {
  static const String serviceType = '_fileshare._tcp'; // The app's unique identifier
  BonsoirBroadcast? _broadcast; // The bonsoir engine
  StreamSubscription<BonsoirBroadcastEvent>? _broadcastSubscription;
  BroadcastState _state = BroadcastState.idle;
  String? _lastError;
  BroadcastState get state => _state;
  bool get isBroadcasting => _state == BroadcastState.broadcasting;
  String? get lastError => _lastError;

  Future<void> startBroadcasting({required String deviceName, required int port}) async {
    if(state != BroadcastState.idle) return;
    _state = BroadcastState.starting;
    _lastError = null;
    final BonsoirService service = BonsoirService(
      name: deviceName,
      type: serviceType,
      port: port,
      attributes: {
        'version': '1.0.0',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
        'platform': 'flutter'
      }
    );
    try {
      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.initialize();
      _broadcastSubscription = _broadcast!.eventStream?.listen((event) {
        _handleBroadcastEvent(event);
      }, onError: (error) async {
         debugPrint('Stream Broadcasting Error $error');
         await _handleFailure(error.toString());
      }
      );
      await _broadcast!.start();
      debugPrint('Broadcasting command started successfully');
    } catch(e) {
      debugPrint('Broadcasting failed completely during initialization');
      if(_state!=BroadcastState.idle) {
        // Guards against reentrance. Handles exception only if onError hasn't already clean up the state and set it to idle.
        await _handleFailure(e.toString());
      }
    }
    }
  Future<void> stopBroadcasting() async {
    if (_state == BroadcastState.idle || _state == BroadcastState.stopping) return;
    _state = BroadcastState.stopping;
    try{
      await _broadcastSubscription?.cancel();
      _broadcastSubscription = null;
      if(_broadcast !=null) {
        await _broadcast!.stop();
      }
    } catch(e) {
      debugPrint('Error Stopping Broadcast $e');
    } finally {
      _broadcast = null;
      _state = BroadcastState.idle;
      debugPrint('Broadcast state reset to idle');
    }
  }

  void _handleBroadcastEvent(BonsoirBroadcastEvent event) {
    if (_state == BroadcastState.idle || _state == BroadcastState.stopping) return;
    switch(event) {
      case BonsoirBroadcastStartedEvent():
       _state = BroadcastState.broadcasting;
       debugPrint('Service is currently broadcasting');
       break;
      case BonsoirBroadcastStoppedEvent():
       _state = BroadcastState.idle; 
       debugPrint('Broadcasting service has stopped');
       break;
    }
  }
  Future<void> _handleFailure(String errorMessage) async {
    _lastError = errorMessage;
    await _broadcastSubscription?.cancel();
    _broadcastSubscription = null;
    _broadcast = null;
    _state = BroadcastState.idle;
  }
  Future<void> dispose() async {
    await stopBroadcasting();
    debugPrint('Network Broadcasting System successfully destroyed');
  }
}