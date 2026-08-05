import 'dart:async';

import 'package:file_share_app/features/device_discovery/services/device_name_service.dart';
import 'package:file_share_app/features/file_transfer/services/receive_server.dart';
import 'package:file_share_app/features/file_transfer/services/incoming_session.dart';
import 'package:file_share_app/features/file_transfer/views/transfer_progress_screen.dart';
import 'package:file_share_app/shared/widgets/radar_pulse_animation.dart';
import 'package:flutter/material.dart';

// Placeholder for Receive Screen
class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}
class _ReceiveScreenState extends State<ReceiveScreen> {
  StreamSubscription<IncomingSession>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _sessionSubscription = ReceiveServer.instance.incomingSessionStream.listen((session) {
      _showIncomingDialog(session);
    });
  }

  void _showIncomingDialog(IncomingSession session) {
    final totalSize = session.files.fold<int>(0, (sum, f) => sum + f.size);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Incoming files',
        style: TextStyle(
          color: Colors.white
        )
        ),
        content: Text(
          '${session.senderName} wants to send ${session.files.length} file(s),'
          '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ReceiveServer.instance.respondToSession(
                session.sessionId, false);
                Navigator.pop(context);
            }, 
            child: const Text(
              'Decline', 
              style: TextStyle(color: Colors.redAccent)
              )
            ),
            ElevatedButton(
              onPressed: () {
                ReceiveServer.instance.respondToSession(
                  session.sessionId, true
                );
                Navigator.pop(context);

                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const TransferProgressScreen(),
                    fullscreenDialog: true,
                  )
                );
              },
              child: const Text('Accept'),
              )
        ],
      )
    );
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerSize = (size.width * 0.5).clamp(150.0, 250.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_rounded, color: Color(0xFF258CFA), size: 20),
                    const SizedBox(width: 10,),
                    const Expanded(
                      child: Text(
                        'Make sure both devices are on the same Wi-Fi network to transfer files.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      )
                    )
                  ],)
              ),
              Expanded(
                child: Center(
                  child: FutureBuilder<String>(
                    future: DeviceNameService.getDeviceName(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator(
                          color: Colors.white24
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RadarPulseAnimation(
                            containerSize: containerSize),
                            const SizedBox(height: 24),
                            const Text(
                              'Waiting to receive files',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Visible as "${snapshot.data}"',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13
                              ),
                              textAlign: TextAlign.center,
                            )
                        ]
                      );
                    }
                    ),
                )
              )
            ],
           )
          )
        )
    );
  }
}