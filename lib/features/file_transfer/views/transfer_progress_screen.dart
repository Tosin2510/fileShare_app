import 'dart:async';

import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_tracker.dart';
import 'package:flutter/material.dart';

class TransferProgressScreen extends StatefulWidget{
  const TransferProgressScreen({super.key});

  @override
  State<TransferProgressScreen> createState() => _TransferProgressScreenState();
}

class _TransferProgressScreenState extends State<TransferProgressScreen> {
  TransferDirection _activeTab = TransferDirection.received;
  List<TransferItem> _items = [];
  StreamSubscription<List<TransferItem>>? _sub;

  @override
  void initState() {
    super.initState();
    _items = TransferTracker.instance.items;
    _sub = TransferTracker.instance.itemsStream.listen((items) {
      if (mounted) setState(() => _items = items);
    });
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<TransferItem> get _filteredItems => 
     _items.where((i) => i.direction == _activeTab).toList();

  int get _totalBytes => _filteredItems.fold(0, (sum, i) => sum + i.totalBytes);
  int get _transferredBytes => _filteredItems.fold(0, (sum, i) => sum + i.transferredBytes);

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes/ (1024 * 1024)).toStringAsFixed(1)}MB';
    if (bytes >= 1024) return '${(bytes/ 1024).toStringAsFixed(1)}KB';
    return '${bytes}B';
  }

  IconData _iconFor(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType.startsWith('video/')) return Icons.videocam_rounded;
    if (mimeType.startsWith('audio/')) return Icons.music_note_rounded;
    if (mimeType == 'application/vnd.android.package-archive') return Icons.android_rounded;
    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double overallProgress = _totalBytes == 0 ? 0 : _transferredBytes / _totalBytes;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              const Text(
                'Transferring',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                children: [
                  _buildTab('RECEIVED', TransferDirection.received),
                  _buildTab('SENT', TransferDirection.sent),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ClipRRect(
             borderRadius: BorderRadiusGeometry.circular(10),
             child: Stack(
              children: [
                Container(
                  height: 32,
                  color: const Color(0xFF1F1F1F)
                ),
                FractionallySizedBox(
                  widthFactor: overallProgress.clamp(0, 1),
                  child: Container(
                    height: 32,
                    color: const Color(0xFF258CFA)
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${_formatBytes(_transferredBytes)}/${_formatBytes(_totalBytes)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )
                        )
                      ],
                    ),
                  )
                )
              ],
             ),
            ),
            const SizedBox(height: 16,),
            Flexible(
              child: _filteredItems.isEmpty
                 ? Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.06),
                  child: Center(
                    child: Text(
                      _activeTab == TransferDirection.received
                         ? 'No files received yet'
                         : 'No files sent yet',
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) => _buildItemRow(_filteredItems[index]), 
                  separatorBuilder: (_, _) => const SizedBox(height: 10), 
                  itemCount: _filteredItems.length
                )
            )
        ],
      ),
    );
  }
  Widget _buildTab(String label, TransferDirection direction) {
    final bool isActive = _activeTab == direction;
    return Expanded(
      child: GestureDetector(
        onTap:() => setState(() => _activeTab = direction),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF258CFA) : Colors.transparent,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      )
    );
  }
  
  Widget _buildItemRow(TransferItem item) {
    return  Container(
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
            child: Icon(_iconFor(item.mimeType), color: Colors.white, size: 22,),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4,),
                Text(
                  '${_formatBytes(item.totalBytes)} • ${_statusLabel(item.status)}',
                  style: TextStyle(
                    color: item.status == TransferStatus.failed
                       ? Colors.redAccent
                       : Colors.white54,
                    fontSize: 12,
                  ),
                )
              ],
            )
          ),
          _buildTrailing(item),
        ],
      ),
    );
  }

  String _statusLabel(TransferStatus status) {
    switch (status) {
      case TransferStatus.waiting: 
        return 'Waiting';
      case TransferStatus.inProgress:
        return 'In progress';
      case TransferStatus.paused:
       return 'Paused';
      case TransferStatus.done:
        return 'Done';
      case TransferStatus.failed:
        return 'Failed';
    }
  }

  Widget _buildTrailing(TransferItem item) {
    switch (item.status) {
      case TransferStatus.inProgress:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            value: item.progress,
            color: const Color(0xFF258CFA),
            backgroundColor: Colors.white12,
          ),
        );

        case TransferStatus.waiting:
          return const SizedBox(width: 24, height: 24,);
        case TransferStatus.paused:
          return OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF258CFA)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
            ),
            child: const Text(
              'Resume',
              style: TextStyle(
                color: Color(0xFF258CFA),
                fontSize: 12
              ),
            )
          );
        case TransferStatus.done:
          if (item.mimeType.startsWith('audio/') && item.direction == TransferDirection.received) {
            return TextButton(
              onPressed: null, 
              child: const Text('Play', style: TextStyle(color: Color(0xFF258CFA), fontSize: 12)),
            );
          }
          return const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 22,);
        case TransferStatus.failed: 
          return const Icon(Icons.error_rounded, color: Colors.redAccent, size: 22,);
    }
  }
}