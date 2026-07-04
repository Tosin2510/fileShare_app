import 'package:flutter/material.dart';

// Placeholder for Receive Screen
// To be worked on
class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Navigation: Receive Screen Clicked");
    return const Scaffold(
      backgroundColor: Colors.black, // Matches your dark theme
      body: Center(
        child: Text(
          "Receive",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}