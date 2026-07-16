import 'package:file_share_app/features/network_join/hotspot_info.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class WifiScannerScreen extends StatefulWidget {
  const WifiScannerScreen({super.key});

  @override
  State<WifiScannerScreen> createState() => _WifiScannerScreenState();
}
class _WifiScannerScreenState extends State<WifiScannerScreen> {
  bool _handled = false;
  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if(raw == null) return;

    try{
      final info = HotspotInfo.fromJsonString(raw);
      _handled = true;
      Navigator.pop(context, info);
    } catch(e) {
      // Invalid. Scanning can continue.
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scan Device QR',
        style: TextStyle(color: Colors.white)
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Enter details manually instead'),
            )
          )
        ]
      )
    );
  }
}