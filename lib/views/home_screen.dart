import 'package:file_share_app/shared/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/widgets/action_icon_button.dart';
import '../shared/widgets/radar_pulse_animation.dart';

class FileShareHome extends StatefulWidget {
  const FileShareHome({super.key});

  @override
  State<FileShareHome> createState() => _FileShareHomeState();
}

class _FileShareHomeState extends State<FileShareHome> {

  Future<void> _refreshUponNavigation(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomBottomNavBar(initialIndex: index)
      )
    );
    if(mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.height < 700;
    final double containerSize = (size.width * 0.6).clamp(180.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.05),
                  
                  // Pure, single-line implementation of the animated radar pulse effect.
                  FutureBuilder<bool>(
                    future: SharedPreferences.getInstance().then((val) => val.getBool('animation_enabled') ?? true),
                    builder: (context, snapshot) {
                      return RadarPulseAnimation(
                        containerSize: containerSize,
                        isAnimated: snapshot.data ?? true,
                    );
                    }
                  ),

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
                          onTap: () => _refreshUponNavigation(0),
                        ),
                        ActionIconButton(
                          title: "Receive",
                          icon: Icons.file_download_outlined,
                          containerSize: containerSize,
                          onTap: () => _refreshUponNavigation(1), 
                        ),
                        ActionIconButton(
                          title: "History",
                          icon: Icons.history_rounded,
                          containerSize: containerSize,
                          onTap: () => _refreshUponNavigation(2),
                        ),
                        ActionIconButton(
                          title: "Settings",
                          icon: Icons.settings_outlined,
                          containerSize: containerSize,
                          onTap: () => _refreshUponNavigation(3),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
      ),
      ),
    );
  }
}