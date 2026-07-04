import 'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_share_app/features/device_discovery/services/network_discovery.dart';
import 'package:file_share_app/features/device_discovery/widgets/build_device_tile.dart';
import 'package:file_share_app/features/device_discovery/widgets/build_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
class DeviceListScreen extends StatefulWidget {
  final List<PlatformFile> selectedFiles;
  final List<AssetEntity> selectedMediaFiles;

  const DeviceListScreen({
    super.key,
    required this.selectedFiles,
    required this.selectedMediaFiles
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
    for (int i=0; i< 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if(_devices.isNotEmpty) break;
    }
    _refreshAnimation.stop();
    _refreshAnimation.reset();
    if(mounted) setState(() => _isRefreshing = false);
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
                    isScanning: isScanning
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
                        onTap:() {
                          debugPrint("Tapped on $device.name");
                        },
                      );
                    }
                    )
                  )
            ]
          ),
          );
  }
}
