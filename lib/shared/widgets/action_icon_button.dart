 import 'package:flutter/material.dart';

 class ActionIconButton extends StatelessWidget {
  // A reusable widget for category selection.
  final String title;
  final IconData icon;
  final double containerSize;
  final VoidCallback onTap;
// immutable wigdget that takes in the title, icon, size, and onTap callback for each category button.
  const ActionIconButton({
    super.key,
    required this.title,
    required this.icon,
    required this.containerSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(48),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),                                                                                                                              
            borderRadius: BorderRadius.circular(48),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: containerSize * 0.15,
              ),
              SizedBox(height: containerSize * 0.05),
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: containerSize * 0.07,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
        ),
      ),
    ));
  }
}