import 'package:flutter/material.dart';
import 'dart:math' as math;

class FileShareHome extends StatefulWidget {
  const FileShareHome({super.key});

  @override
  State<FileShareHome> createState() => _FileShareHomeState();
}

class _FileShareHomeState extends State<FileShareHome> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800), 
    );

    _rotationAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _pulseOpacity = Tween<double>(begin: 0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.9, curve: Curves.linear),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.height < 700;
    
    // NEW: This is the size of your square container (60% of screen width)
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
                SizedBox(
                  width: containerSize, 
                  height: containerSize,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. THE PULSE (Was 150, now 60% of the container)
                          Transform.scale(
                            scale: _pulseScale.value,
                            child: Container(
                              width: containerSize * 0.6,
                              height: containerSize * 0.6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF258CF4).withValues(alpha: _pulseOpacity.value),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF258CF4).withValues(alpha: _pulseOpacity.value),
                                    blurRadius: containerSize * 0.15, // Glow scales with size
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
          
                          // 2. MAIN BUTTON (Was 180, now 70% of the container)
                          Container(
                            width: containerSize * 0.7,
                            height: containerSize * 0.7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF000000).withValues(alpha: 0.5),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF258CF4).withValues(alpha: 0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
          
                          // 3. THE ICON (Was 64, now 25% of the container)
                          Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Icon(
                              Icons.swap_calls_rounded,
                              size: containerSize * 0.25,
                              color: const Color(0xFF258CF4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 40),
                Text('FileShare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: containerSize * 0.18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text("Fast, Secure. No internet needed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFCBD5E1), 
                  fontSize: containerSize * 0.075,
                  fontWeight: FontWeight.w400,
                ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}