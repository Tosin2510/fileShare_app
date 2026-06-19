import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NetworkBroadcasting {
  static const String serviceType = '_fileshare._tcp'; // The app's unique identifier
  BonsoirBroadcast? _broadcast; // The bonsoir engine
  StreamSubscription<BonsoirBroadcastEvent>? _broadcastSubscription;
  bool _isBroadcasting = false;
  bool _isStarting = false;

  bool get isBroadcasting => _isBroadcasting;
  bool get isStarting => _isStarting;
  Future<void> startBroadcasting({required String deviceName, required int port}) async {
    if (_isBroadcasting || _isStarting) return;
    _isStarting = true;
    final BonsoirService service = BonsoirService(
      name: deviceName,
      type: serviceType,
      port: port,
      attributes: {
        'version': '1.0.0',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
        'platform': 'flutter'
      }
    );
    _broadcast = BonsoirBroadcast(service: service);
      try{
        await _broadcast!.initialize();
        _broadcastSubscription = _broadcast!.eventStream?.listen((event) {
          switch(event) {
            case BonsoirBroadcastStartedEvent():
              _isBroadcasting = true;
              _isStarting = false;
              debugPrint("Service is actively broadcasting");
              break;
            case BonsoirBroadcastStoppedEvent():
              _isBroadcasting = false;
              debugPrint('Service broadcast has stopped');
              break;
            default: break;
          }
        },
        onError: (error) {
          debugPrint('Stream Broadcasting error $error');
          _isStarting = false;
          _isBroadcasting = false;});

          await _broadcast!.start();
          _isStarting = false;
          debugPrint('Broadcasting start command successfully executed');

        } catch(e) {
          debugPrint('Broadcasting failed completely during initialization $e');
          await _broadcastSubscription?.cancel();
          _broadcastSubscription = null;
          _isBroadcasting = false;
          _isStarting = false;
          _broadcast = null;
        }
  }
  Future<void> stopBroadcasting() async {
    if (_broadcast != null) {
      try{
        await _broadcastSubscription?.cancel();
       _broadcastSubscription = null;
       await _broadcast!.stop();
       } catch (e) {
        debugPrint('Error stopping broadcast: $e');
       } finally {
        _broadcast = null;
        _isBroadcasting = false;
        _isStarting = false;
        debugPrint('Broadcast state fully reset');
       }
    }
  }
}