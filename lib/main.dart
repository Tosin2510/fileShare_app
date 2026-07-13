import 'package:file_share_app/features/device_discovery/services/device_name_service.dart';
import 'package:file_share_app/features/device_discovery/services/network_broadcasting.dart';
import 'package:file_share_app/features/file_transfer/services/http_server_service.dart';
import 'package:file_share_app/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // This defines DeviceOrientation

void main() {
  // Ensure orientation is locked to portrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the app.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      title: 'FileShare',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const AppRoot(),
    );
  }
}
class AppRoot extends StatefulWidget{
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}
class _AppRootState extends State<AppRoot> {
  final NetworkBroadcasting _broadcasting = NetworkBroadcasting();
  final ReceiveServer _receiveServer = ReceiveServer.instance;

  @override
  void initState() {
    super.initState();
    _initBroadcasting();
    _receiveServer.start();
  }
  @override
  void dispose() {
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