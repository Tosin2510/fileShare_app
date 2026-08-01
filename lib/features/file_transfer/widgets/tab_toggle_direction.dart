import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:flutter/material.dart';

class TabToggleDirection extends StatelessWidget {
  final TransferDirection active;
  final ValueChanged<TransferDirection> onChanged;
  const TabToggleDirection({super.key, required this.active, required this.onChanged});

  @override 
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab('RECEIVED', TransferDirection.received),
          _tab('SENT', TransferDirection.sent),
        ]
      )
    );
  }

  Widget _tab(String label, TransferDirection direction) {
    final bool isActive = active == direction;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(direction),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF258CFA) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            )
          )
        )
      ),
    );
  }
}