import 'package:flutter/material.dart';

// Placeholder for Settings Screen
// To be worked/ improved on.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Navigation: Settings Screen Clicked");
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}