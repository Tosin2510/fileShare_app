// lib/widgets/radar_pulse_animation.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class RadarPulseAnimation extends StatefulWidget {
  final double containerSize;
  final bool isAnimated;

  const RadarPulseAnimation({
    super.key,
    required this.containerSize,
    this.isAnimated = true,
  });

  @override
  State<RadarPulseAnimation> createState() => _RadarPulseAnimationState();
}

class _RadarPulseAnimationState extends State<RadarPulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> rotationAnimation;
  late Animation<double> pulseScale;
  late Animation<double> pulseOpacity;

  @override
  void initState() {
    super.initState();
    
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800), 
    );

    rotationAnimation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    pulseScale = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    pulseOpacity = Tween<double>(begin: 0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.9, curve: Curves.linear),
      ),
    );

    if (widget.isAnimated) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.containerSize, 
      height: widget.containerSize,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // The pulsing effect...
              if (widget.isAnimated)
              Transform.scale(
                scale: pulseScale.value,
                child: Container(
                  width: widget.containerSize * 0.6,
                  height: widget.containerSize * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF258CF4).withValues(alpha: pulseOpacity.value),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF258CF4).withValues(alpha: pulseOpacity.value),
                        blurRadius: widget.containerSize * 0.15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              
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
  
              Transform.rotate(
                angle: widget.isAnimated ? rotationAnimation.value : 0,
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