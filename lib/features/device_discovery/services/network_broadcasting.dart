import 'package:bonsoir/bonsoir.dart';
import 'package:file_share_app/constants/app_constant.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// The enum handles the varoious state the broadcasting service can be in.
enum BroadcastState {idle, starting, broadcasting, stopping}
class NetworkBroadcasting {
  BonsoirBroadcast? _broadcast; // The bonsoir engine
  StreamSubscription<BonsoirBroadcastEvent>? _broadcastSubscription;
  BroadcastState _state = BroadcastState.idle;
  String? _lastError;
  BroadcastState get state => _state;
  bool get isBroadcasting => _state == BroadcastState.broadcasting;
  String? get lastError => _lastError;

// This is where the broadcasting starts, a device name is needed and a port where the shouting takes place.
  Future<void> startBroadcasting({required String deviceName}) async {
    if(state != BroadcastState.idle) return;
    _state = BroadcastState.starting;
    _lastError = null;
    final BonsoirService service = BonsoirService(
      name: deviceName,
      type: AppConstant.serviceType,
      port: AppConstant.transferPort,
      attributes: {
        'version': '1.0.0',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
        'platform': 'flutter'
      }
    );
    try {
      // Preparation for the broadcasting action, initialization of bonsoir engine and all.
      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.initialize();
      _broadcastSubscription = _broadcast!.eventStream?.listen((event) {
        _handleBroadcastEvent(event);
      }, onError: (error) async {
         debugPrint('Stream Broadcasting Error $error');
         await _handleFailure(error.toString());
      }
      );
      // Broadcasting to other devices on the local network starts here.
      await _broadcast!.start();
      debugPrint('Broadcasting command started successfully');
    } catch(e) {
      debugPrint('Broadcasting failed completely during initialization');
      if(_state!=BroadcastState.idle) {
        await _handleFailure(e.toString());
      }
    }
    }

    // Stop the broadcaasting action/service.
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
      _state = BroadcastState.idle; // Reset back to idle always at the end of broadcasting.
      debugPrint('Broadcast state reset to idle');
    }
  }

// Change the state of the app based on broadcasting actions or even events.
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
  // Handle cases when the broadcasting process fails.
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