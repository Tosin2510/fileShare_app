import 'dart:async';
import 'dart:io';

import 'package:file_share_app/features/device_discovery/services/device_name_service.dart';
import 'package:file_share_app/features/device_discovery/services/network_broadcasting.dart';
import 'package:file_share_app/features/file_transfer/services/incoming_session.dart';
import 'package:file_share_app/features/file_transfer/services/receive_server.dart';
import 'package:file_share_app/features/file_transfer/views/transfer_progress_screen.dart';
import 'package:file_share_app/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_store_plus/media_store_plus.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid) {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = 'FileShare';
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FileShare',
      theme: ThemeData(useMaterial3: true),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget { // ADD THIS BACK
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  final NetworkBroadcasting _broadcasting = NetworkBroadcasting();
  final ReceiveServer _receiveServer = ReceiveServer.instance;
  StreamSubscription<IncomingSession>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initBroadcasting();
    _receiveServer.start();
    _sessionSubscription = _receiveServer.incomingSessionStream.listen((session) {
      _showIncomingGlobalDialog(session);
    });
  }

  void _showIncomingGlobalDialog(IncomingSession session) {
    final cont = rootNavigatorKey.currentContext;
    if (cont == null) return;
    final totalFileSizes = session.files.fold<int>(0, (sum, fn) => sum + fn.size);
    showDialog(
      context: cont, 
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text(
          'Incoming files',
          style: TextStyle(color: Colors.white), 
        ),
        content: Text(
          '${session.senderName} wants to send ${session.files.length} file(s),'
          '${(totalFileSizes / (1024 * 1024)).toStringAsFixed(1)} MB',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _receiveServer.respondToSession(session.sessionId, false);
              Navigator.pop(cont);
            },
            child: const Text('Decline', style: TextStyle(color: Colors.redAccent))
          ),
          ElevatedButton(
            onPressed: () {
              _receiveServer.respondToSession(session.sessionId, true);
              Navigator.pop(cont);
              rootNavigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => const TransferProgressScreen()),
              );
            },
            child: const Text('Accept'),
          )
        ]
      )
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('=== LIFECYCLE === $state at ${DateTime.now()}');
  }

  @override
  void dispose() {
    debugPrint('=== APPROOT DISPOSE CALLED at ${DateTime.now()} ===');
    WidgetsBinding.instance.removeObserver(this);
    _sessionSubscription?.cancel();
    _broadcasting.dispose();
    _receiveServer.dispose();
    super.dispose();
  }

  Future<void> _initBroadcasting() async {
    final deviceName = await DeviceNameService.getDeviceName();
    await _broadcasting.startBroadcasting(deviceName: deviceName);
  }

  @override
  Widget build(BuildContext context) {
    return const FileShareHome();
  }
}