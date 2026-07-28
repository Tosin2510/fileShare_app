import 'dart:async';

import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_tracker.dart';
import 'package:file_share_app/features/file_transfer/views/transfer_progress_screen.dart';
import 'package:file_share_app/main.dart';
import 'package:flutter/material.dart';

class RollingTransferButton extends StatefulWidget{

  const RollingTransferButton({super.key,});

  @override
  State<RollingTransferButton> createState() => _RollingTransferButtonState();
}

class _RollingTransferButtonState extends State<RollingTransferButton> with SingleTickerProviderStateMixin {
List<TransferItem> _transferItems = [];
StreamSubscription<List<TransferItem>>? _sub;

  @override
  void initState() {
    super.initState();
    _transferItems = TransferTracker.instance.items;
    _sub = TransferTracker.instance.itemsStream.listen((items) {
      if (mounted) {
        setState(() => _transferItems = items);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
  bool get _isTransferActive => 
     _transferItems.any((val) => val.status == TransferStatus.inProgress || val.status == TransferStatus.waiting);

  double get _transferProgress {
    final activeTransfers = _transferItems.where((val) => val.status == TransferStatus.inProgress || val.status == TransferStatus.inProgress || val.status == TransferStatus.waiting,);
    if (activeTransfers.isEmpty) return 0;
    final totalStuff = activeTransfers.fold<int>(0, (sum, val) => sum + val.totalBytes);
    final completed = activeTransfers.fold<int>(0, (sum, val) => sum + val.transferredBytes);
    return totalStuff == 0? 0 : completed / totalStuff;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTransferActive) {
      return const SizedBox.shrink();
    }
    return Positioned(
      right: 16,
      bottom: 24,
      child: GestureDetector(
        onTap: () {
          rootNavigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => const TransferProgressScreen(),
              fullscreenDialog: true,
          )          
        );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
              )        
            ]
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: _transferProgress,
                  strokeWidth : 3,
                  color: const Color(0xFF258CFA),
                  backgroundColor: Colors.white12,
                )
              ),
              const Icon(
                Icons.upload_rounded,
                color: Colors.white, size: 20,
              )          
            ]
          )
        )
      )
    );
  }
}