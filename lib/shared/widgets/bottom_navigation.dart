import 'package:file_share_app/features/history/views/history_screen.dart';
import 'package:file_share_app/features/file_transfer/views/receive_screen.dart';
import 'package:file_share_app/features/file_transfer/views/send_screen.dart';
import 'package:file_share_app/features/settings/views/settings.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int initialIndex; // Starting index for the bottom nav.
  const CustomBottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // This initialize the initial index for the nav.bar
    _currentIndex = widget.initialIndex;
  }

  // A list of all the screens corresponding to each tab
  // I have created these screen in differeny files.
  final List<Widget> _screens = [
    const SendScreen(),
    const ReceiveScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  // The build part.
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.09,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Color(0xFF000000), // Pure Black Figma Match
          border: Border(
            top: BorderSide(color: Color(0xFF2C2C2C), width: 1), // Figma Stroke Match
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // For each of the tabs, the navigation property...
            _buildNavigTab("Send", Icons.send_rounded, 0, screenWidth),
            _buildNavigTab("Receive", Icons.download_rounded, 1, screenWidth),
            _buildNavigTab("History", Icons.history_rounded, 2, screenWidth),
            _buildNavigTab("Settings", Icons.settings_rounded, 3, screenWidth),
          ],
        ),
      ),
    );
  }

// I created this function to show the active and inactive tabs
// The colour of the icon and text change depending on the state of the tab(whether active or not).
  Widget _buildNavigTab(String title, IconData icon, int index, double sw) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: sw / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF258CF4) : const Color(0xFF9DA6B9),
              size: sw * 0.065,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isActive ? const Color(0xFF258CF4) : const Color(0xFF9DA6B9),
                fontSize: sw * 0.03,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}