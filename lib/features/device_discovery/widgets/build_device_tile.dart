import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
// Device tile for available device on the local network.
class BuildDeviceTile extends StatelessWidget{
  final BonsoirService device;
  final double containerSize;
  final VoidCallback? onTap;

  static const Color _cardColor = Color(0xFF1F1F1F);
  static const Color _accentBlue = Color(0xFF334155);
  static const Color _subtleText = Color(0xFF9DA6B9);
  const BuildDeviceTile({
    super.key,
    required this.device,
    required this.containerSize,
    required this.onTap

  });
  // Depending on the platorm, the icon will change.
  IconData _deviceIcon(String platform) {
    switch(platform.toLowerCase()) {
      case 'android':
        return Icons.android_rounded;
      case 'ios':
        return Icons.apple_rounded;
      default:
        return Icons.phone_android_rounded;
    }
  }
  @override
  // The build...
  Widget build(BuildContext context) {
    final String platform = device.attributes['platform']?.toUpperCase() ?? 'UNKNOWN';
    final String version = device.attributes['version'] ?? '';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: containerSize * 0.06,
          vertical: containerSize * 0.055,
        ),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(containerSize * 0.06),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
            ),
        ),
        child: Row(
          children: [
            Container(
              width: containerSize * 0.14,
              height: containerSize * 0.14,
              decoration: BoxDecoration(
                color: _accentBlue,
                borderRadius: BorderRadius.circular(containerSize * 0.04),
              ),
              child: Icon(
                _deviceIcon(platform),
                color: Colors.white,
                size: containerSize*0.09,
              ),
              ),
              SizedBox(width: containerSize * 0.05),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: containerSize * 0.09,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: containerSize * 0.01),
                      Text(
                        // The port, the version as well as the platform displayed.
                        '#${device.port}  •  $platform${version.isNotEmpty? '  v$version': ''}',
                        style: TextStyle(
                          color: _subtleText,
                          fontSize: containerSize * 0.06,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3
                        ),
                      ),
                  ],
                  ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: containerSize * 0.1,
                )
        ],)
      )
      );
  }
}