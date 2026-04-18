import 'package:file_share_app/send_screen.dart';
import 'package:flutter/material.dart';
class ButtomNavigationBar extends StatefulWidget {
  const ButtomNavigationBar({super.key});

  @override
  State <ButtomNavigationBar> createState() => _ButtomNavigationBarState();
}
class _ButtonNavigationBarState extends State<ButtomNavigationBar> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const SendScreen(),
    const ReceiveScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];
  @override
}