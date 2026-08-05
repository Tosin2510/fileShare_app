import 'package:flutter/material.dart';
class BuildEmptyState extends StatelessWidget{
  final double containerSize;
  final bool isScanning;

  const BuildEmptyState({
    super.key,
    required this.containerSize,
    required this.isScanning,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isScanning
            ? Icons.wifi_find_rounded
            : Icons.wifi_off_rounded,
          color: Colors.white12,
          size: containerSize * 0.35,
          ),
          SizedBox(height: containerSize * 0.06),
          Text(
            isScanning ? 'Looking for devices..': 'No devices found',
            style: TextStyle(
              color: Colors.white38,
              fontSize: containerSize * 0.09,
              fontWeight: FontWeight.w500,
            )
          ),
          SizedBox(height: containerSize * 0.02),
          Text(
            isScanning? 
            'Make sure other devices have the app open':
            'Tap refresh to scan again',
          style: TextStyle(
            color: Colors.white24,
            fontSize: containerSize *0.07,
          ),
          textAlign: TextAlign.center,
            ),
        ]
      )
      );
  }
}