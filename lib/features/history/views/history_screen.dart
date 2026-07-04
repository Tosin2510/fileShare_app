import 'package:flutter/material.dart';

// Placeholder for History Screen
// To be worked on
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Navigation: History Screen Clicked");
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "History",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
