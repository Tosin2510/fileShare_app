import 'package:file_share_app/features/file_transfer/models/transfer_tile.dart';
import 'package:flutter/material.dart';

class FileTransferTile extends StatelessWidget{
final TransferTile data;
const FileTransferTile({super.key, required this.data});

@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1F1F1F),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(data.icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.fileName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4,),
              Text(
                data.statusLabel != null ? '${data.sizeLabel} • ${data.statusLabel}' : data.sizeLabel,
                style: TextStyle(
                  color: data.statusColor ?? Colors.white54,
                  fontSize: 12,
              )
            )
            ],
          ),
        ),
        data.trailing,
      ]
    )
  );
}
}