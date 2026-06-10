import 'package:flutter/material.dart';
class SendSelectionButton extends StatelessWidget {
  final String buttonRep;
  final IconData icon;
  final double containerSize;
  final bool isActive;
  final Color activeTabBackground;
  final Color inactiveTabBackground;
  final Color inactiveTabText;
  final VoidCallback onTap;

  const SendSelectionButton({
    super.key,
    required this.buttonRep,
    required this.icon,
    required this.containerSize,
    required this.isActive,
    required this.activeTabBackground,
    required this.inactiveTabBackground,
    required this.inactiveTabText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: containerSize * 0.35,
              height: containerSize * 0.35,
              decoration: BoxDecoration(
                color: isActive ? activeTabBackground : inactiveTabBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.6),
                  size: containerSize * 0.14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              buttonRep,
              style: TextStyle(
                color: isActive ? activeTabBackground : inactiveTabText,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            )
          ],
          )
        )
      );
  }
}
