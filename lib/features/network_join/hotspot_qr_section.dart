import 'package:app_settings/app_settings.dart';
import 'package:file_share_app/features/device_discovery/services/device_name_service.dart';
import 'package:file_share_app/features/network_join/hotspot_info.dart';
import 'package:file_share_app/features/network_join/hotspot_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HotspotQrSection extends StatefulWidget {
  const HotspotQrSection({super.key});

  @override
  State<HotspotQrSection> createState() => _HotspotQrSectionState();
}
class _HotspotQrSectionState extends State<HotspotQrSection> {
  HotspotInfo? _hotspotInfo;
  bool _loading = false;
  String? _error;

  Future<void> _generateQr() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final details = await HotspotService.getCurrentHotspotDetails();
    if (details == null) {
      setState(() {
        _loading = false;
        _error = 'Could not read hotspot info. Make sure your hotspot is turned on';
      });
      return;
    }
    final deviceName = await DeviceNameService.getDeviceName();
    setState((){
      _hotspotInfo = HotspotInfo(
        ssid: details.ssid, 
        password: details.password, 
        deviceName: deviceName,
        );
        _loading = false;
    });
  }
  void _reset() {
    setState(() {
      _hotspotInfo = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _hotspotInfo == null ? _buildGenerateState() : _buildQrState(),
    );
  }
  Widget _buildGenerateState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Not on the sender\'s network?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        ),
        const SizedBox(height: 4),
        const Text('Turn on your hotspot, then confirm below.',
        style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.wifi), 
                child: const Text('Hotspot Settings'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _generateQr, 
                  child: _loading
                     ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white
                      ),
                     )
                     : const Text('I\'ve turned it on'),
                )
              ),
          ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13
            )
            )
          ]
      ],
      );
  }
  Widget _buildQrState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: QrImageView(
            data: _hotspotInfo!.toJsonString(),
            size: 180,
            )
        ),
        const SizedBox(height: 12),
        Text(
          _hotspotInfo!.deviceName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Let the sender scan this to connect',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _reset, 
          child: const Text('Hide')
          )
      ]
    );
  }
}