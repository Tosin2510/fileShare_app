import 'dart:async';
// import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_share_app/features/device_discovery/services/device_name_service.dart';
import 'package:file_share_app/features/device_discovery/services/network_discovery.dart';
import 'package:file_share_app/features/device_discovery/widgets/build_device_tile.dart';
import 'package:file_share_app/features/device_discovery/widgets/build_empty_state.dart';
import 'package:file_share_app/features/file_transfer/services/outgoing_file_converter.dart';
import 'package:file_share_app/features/file_transfer/services/send_service.dart';
import 'package:file_share_app/features/file_transfer/views/transfer_progress_screen.dart';
import 'package:file_share_app/features/network_join/hotspot_info.dart';
import 'package:file_share_app/features/network_join/screens/wifi_scanner_screen.dart';
import 'package:file_share_app/main.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wifi_iot/wifi_iot.dart';

class DeviceListScreen extends StatefulWidget {
  final List<PlatformFile> selectedFiles;
  final List<AssetEntity> selectedMediaFiles;
  final VoidCallback onTransferComplete;

  const DeviceListScreen({
    super.key,
    required this.selectedFiles,
    required this.selectedMediaFiles,
    required this.onTransferComplete,
  });
  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}
class _DeviceListScreenState extends State<DeviceListScreen> with SingleTickerProviderStateMixin {
  final NetworkDiscovery _networkDiscovery = NetworkDiscovery();
  List<BonsoirService> _devices = [];
  StreamSubscription<List<BonsoirService>>? _deviceSubscription;
  late AnimationController _refreshAnimation;
  bool _isRefreshing = false;
  final Color _subtleText = const Color(0xFCCCCCCC);
  final SendService _sendService = SendService();
  bool _isSending = false;

  Future<void> _startScanning() async {
    _deviceSubscription = _networkDiscovery.deviceStream.listen((devices){
      if(mounted) setState(() => _devices = devices);
    });
    await _networkDiscovery.startScanning();
    if(mounted) setState(() {});
  }
  @override
  void initState() {
    _refreshAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    super.initState();
    _startScanning();
  }
  @override
  void dispose() { 
    _refreshAnimation.dispose();
    _deviceSubscription?.cancel();
    _networkDiscovery.dispose();
    super.dispose();
  }
  Future<void> _refresh() async {
    if(_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _refreshAnimation.repeat(reverse: true); // Start the scan
    setState(() => _devices = []);
    await _networkDiscovery.stopScanning();
    await _startScanning();
    await Future.delayed(const Duration(seconds: 3));
    if(mounted) {
      _refreshAnimation.stop();
      _refreshAnimation.reset();
      if(mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _handleDeviceTap(BonsoirService device) async {
    debugPrint('=== TAP DEBUG === Device tapped: ${device.name}');
    final String? ip = device.hostAddress;
    if (ip == null) {
      debugPrint('No Ip address found for ${device.name}');
      return;
    }
    if (_isSending) return; // Added this guard condition against double taps.
    setState(() => _isSending = true
    );
    try {
    debugPrint('=== TAP DEBUG === Converting files...');
    final outgoingFiles = await OutgoingFileConverter.convertAll(
      platformFiles: widget.selectedFiles,
      mediaFiles: widget.selectedMediaFiles,
    );
    debugPrint('=== TAP DEBUG === Converted ${outgoingFiles.length} files');
    if (outgoingFiles.isEmpty) {
      if (mounted) {
        setState(() => _isSending = false
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No valid files to send.')
            )
        );
      }
      return;
    }
    final senderName = await DeviceNameService.getDeviceName();
    debugPrint('=== TAP DEBUG === Sender name: $senderName');

   rootNavigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => TransferProgressScreen(),
      fullscreenDialog: true,
    )
   );

    final result = await _sendService.sendFiles(
      targetIp: ip, 
      senderDeviceName: senderName, 
      files: outgoingFiles
      );
      debugPrint('=== TAP DEBUG === Result: $result');

      if (!mounted) return;
      setState(() => _isSending = false);

      switch (result) {
        case SendResult.accepted:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transfer complete!')),
            );
            widget.onTransferComplete();
            if(mounted) Navigator.of(context).pop();
            break;
        case SendResult.declined:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${device.name} declined the transfer.')),
          );
          break;
        case SendResult.failed:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File transfer failed.'))
          );
          break;
      }
  } catch(e, stack) {
    debugPrint('===TAP DEBUG === EXCEPTION: $e');
    debugPrint('=== TAP DEBUG === STACK: $stack');
    if (mounted) setState(() => _isSending = false);
  }
}

  Future<void> _handleScanQr() async {
    final HotspotInfo? info = await Navigator.push<HotspotInfo?> (
      context,
      MaterialPageRoute(builder: (_) => const WifiScannerScreen()),
    );
    if (info == null) {
      return;
    }
    final joined = await WiFiForIoTPlugin.connect(
      info.ssid,
      password: info.password,
      security: NetworkSecurity.WPA,
      joinOnce: true,
    );
    if (!mounted) return;
    if(joined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          'Connected to ${info.deviceName}\'s network'
        )),
      );
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content:
        Text('Failed to join network. Try manual WiFi settings.'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerSize = size.width * 0.6;
    final bool isScanning = _networkDiscovery.isScanning;
    return Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: size.width * 0.1,
                  height: size.height * 0.005,
                  margin: EdgeInsets.symmetric(vertical: size.height * 0.015),
                  decoration: BoxDecoration(
                    color:Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(size.height* 0.003),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Nearby Devices",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: containerSize * 0.14,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _refresh,
                    child: SizedBox(
                      width: containerSize * 0.14,
                      height: containerSize * 0.14,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if(_isRefreshing)
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF258CFA).withValues(alpha: 0.4),
                          ),
                          RotationTransition(
                            turns: _refreshAnimation,
                            child: Icon(
                              Icons.refresh_rounded,
                              color: _isRefreshing ? const Color(0xFF258CFA): Colors.white54,
                              size: containerSize * 0.1,
                            )
                            )
                        ]                      )
                  ),
                  )
                ]
              ),
              SizedBox(height: containerSize * 0.03),
              Text(
                'Devices with the app opened will appear here.',
                style: TextStyle(
                  color: _subtleText,
                  fontSize: containerSize * 0.075,
                  fontWeight: FontWeight.w400,
                )
                ),
                SizedBox(height: containerSize * 0.060),

                SizedBox(
                  height: size.height * 0.45,
                  child: _devices.isEmpty
                  ? BuildEmptyState(
                    containerSize: containerSize, 
                    isScanning: isScanning,
                    onScanQrTap: _handleScanQr,
                    )
                  : ListView.separated(
                    itemCount: _devices.length,
                    separatorBuilder: (_, _) =>
                       SizedBox(height: containerSize*0.04),
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return BuildDeviceTile(
                        containerSize: containerSize,
                        device: device,
                        onTap:() => _handleDeviceTap(device),
                      );
                    }
                    )
                  )
            ]
          ),
          );
  }
}

