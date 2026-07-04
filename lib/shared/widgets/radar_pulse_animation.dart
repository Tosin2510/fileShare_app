// lib/widgets/radar_pulse_animation.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class RadarPulseAnimation extends StatefulWidget {
  final double containerSize;

  const RadarPulseAnimation({
    super.key,
    required this.containerSize,
  });

  @override
  State<RadarPulseAnimation> createState() => _RadarPulseAnimationState();
}

class _RadarPulseAnimationState extends State<RadarPulseAnimation> with SingleTickerProviderStateMixin {
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
    return SizedBox(
      width: widget.containerSize, 
      height: widget.containerSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. THE PULSE
              Transform.scale(
                scale: _pulseScale.value,
                child: Container(
                  width: widget.containerSize * 0.6,
                  height: widget.containerSize * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF258CF4).withValues(alpha: _pulseOpacity.value),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF258CF4).withValues(alpha: _pulseOpacity.value),
                        blurRadius: widget.containerSize * 0.15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              
              // 2. MAIN HUB BUTTON
              Container(
                width: widget.containerSize * 0.7,
                height: widget.containerSize * 0.7,
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
  
              // 3. THE ROTATING ICON
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: Icon(
                  Icons.swap_calls_rounded,
                  size: widget.containerSize * 0.25,
                  color: const Color(0xFF258CF4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}