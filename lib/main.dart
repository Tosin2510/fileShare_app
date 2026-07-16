import 'package:file_share_app/features/device_discovery/services/device_name_service.dart';
import 'package:file_share_app/features/device_discovery/services/network_broadcasting.dart';
import 'package:file_share_app/features/file_transfer/services/receive_server.dart';
import 'package:file_share_app/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initBroadcasting();
    _receiveServer.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('=== LIFECYCLE === $state at ${DateTime.now()}');
  }

  @override
  void dispose() {
    debugPrint('=== APPROOT DISPOSE CALLED at ${DateTime.now()} ===');
    WidgetsBinding.instance.removeObserver(this);
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