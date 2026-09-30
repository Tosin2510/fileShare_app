import 'package:bonsoir/bonsoir.dart';
import 'package:file_share_app/constants/app_constant.dart';
import 'package:flutter/material.dart';
import 'dart:async';

enum BroadcastState {idle, starting, broadcasting, stopping}
class NetworkBroadcasting {
  BonsoirBroadcast? broadcast;
  StreamSubscription<BonsoirBroadcastEvent>? broadcastSubscription;
  BroadcastState _state = BroadcastState.idle;
  String? _lastError;
  BroadcastState get state => _state;
  bool get isBroadcasting => _state == BroadcastState.broadcasting;
  String? get lastError => _lastError;

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
      broadcast = BonsoirBroadcast(service: service);
      await broadcast!.initialize();
      broadcastSubscription = broadcast!.eventStream?.listen((event) {
        handleBroadcastEvent(event);
      }, onError: (error) async {
         debugPrint('Stream Broadcasting Error $error');
         await handleFailure(error.toString());
      }
      );
      await broadcast!.start();
      debugPrint('Broadcasting command started successfully');
    } catch(e) {
      debugPrint('Broadcasting failed completely during initialization');
      if(_state!=BroadcastState.idle) {
        await handleFailure(e.toString());
      }
    }
    }

  Future<void> stopBroadcasting() async {
    if (_state == BroadcastState.idle || _state == BroadcastState.stopping) return;
    _state = BroadcastState.stopping;
    try{
      await broadcastSubscription?.cancel();
      broadcastSubscription = null;
      if(broadcast !=null) {
        await broadcast!.stop();
      }
    } catch(e) {
      debugPrint('Error Stopping Broadcast $e');
    } finally {
      broadcast = null;
      _state = BroadcastState.idle; 
      debugPrint('Broadcast state reset to idle');
    }
  }

  void handleBroadcastEvent(BonsoirBroadcastEvent event) {
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
  Future<void> handleFailure(String errorMessage) async {
    _lastError = errorMessage;
    await broadcastSubscription?.cancel();
    broadcastSubscription = null;
    broadcast = null;
    _state = BroadcastState.idle;
  }
  Future<void> dispose() async {
    await stopBroadcasting();
    debugPrint('Network Broadcasting System successfully destroyed');
  }
}