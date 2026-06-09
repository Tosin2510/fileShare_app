// lib/views/home_screen.dart

import 'package:file_share_app/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import '../widgets/action_icon_button.dart';
import '../widgets/radar_pulse_animation.dart'; // Import your clean new widget

class FileShareHome extends StatelessWidget {
  const FileShareHome({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.height < 700;
    final double containerSize = size.width * 0.6;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                
                // Pure, single-line implementation of your animation!
                RadarPulseAnimation(containerSize: containerSize),
                
                SizedBox(height: isSmallScreen ? 20 : 40),
                Text(
                  'FileShare',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: containerSize * 0.18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Fast, Secure. No internet needed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFCBD5E1), 
                    fontSize: containerSize * 0.075,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: (size.height * 0.08).clamp(20.0, 80.0)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: size.width * 0.04, 
                    mainAxisSpacing: size.width * 0.04,
                    childAspectRatio: 1.1,
                    children: [
                      ActionIconButton(
                        title: "Send",
                        icon: Icons.near_me_outlined,
                        containerSize: containerSize,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomBottomNavBar(initialIndex: 0)),
                        ),
                      ),
                      ActionIconButton(
                        title: "Receive",
                        icon: Icons.file_download_outlined,
                        containerSize: containerSize,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomBottomNavBar(initialIndex: 1)),
                        ),
                      ),
                      ActionIconButton(
                        title: "History",
                        icon: Icons.history_rounded,
                        containerSize: containerSize,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomBottomNavBar(initialIndex: 2)),
                        ),
                      ),
                      ActionIconButton(
                        title: "Settings",
                        icon: Icons.settings_outlined,
                        containerSize: containerSize,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomBottomNavBar(initialIndex: 3)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}