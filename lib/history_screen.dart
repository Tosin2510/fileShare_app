import 'dart:io';

import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:file_share_app/features/file_transfer/models/transfer_tile.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_history.dart';
import 'package:file_share_app/features/file_transfer/widgets/file_transfer_tile.dart';
import 'package:file_share_app/features/file_transfer/widgets/tab_toggle_direction.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransferDirection _activeTab = TransferDirection.received;
  bool _loading = true;
  List<Map<String, dynamic>> _hist = [];
  bool _selectionMethod = false;
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final rows = await TransferHistoryService.instance.getAllTransferHistory();
    if (mounted) {
      setState(() {
        _loading = false;
        _hist = rows;
      });
    }
  }

  List<Map<String, dynamic>> get _rows => _hist
      .where((r) => r['transferDirection'] == _activeTab.name)
      .toList();

  Map<String, List<Map<String, dynamic>>> get _dateGrouping {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final row in _rows) {
      final timeStamp = row['timeStamp'] as int;
      final date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
      final dateLabel = _dateHeader(date);
      groups.putIfAbsent(dateLabel, () => []).add(row);
    }
    return groups;
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  IconData _icon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType.startsWith('video/')) return Icons.image_rounded;
    if (mimeType.startsWith('audio/')) return Icons.image_rounded;
    if (mimeType == 'application/vnd.android.package-archive/') return Icons.android_rounded;
    return Icons.insert_drive_file_rounded;
  }

  String _byteFormat(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes/ (1024 * 1024)).toStringAsFixed(2)}MB';
    if (bytes >= 1024) return '${(bytes/ 1024).toStringAsFixed(2)}KB';
    return '${bytes}B';
  }

  Future<void> _deleteSelectedHistory() async {
    await TransferHistoryService.instance.deleteTransferHistory(_selectedItemIds.toList());
    setState(() {
      _selectedItemIds.clear();
      _selectionMethod = false;
    });
    await _loadHistory();
  }

  String _dateHeader(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 
      'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF141414),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ],
              ),
              const SizedBox(height: 16,),
              TabToggleDirection(
                active: _activeTab,
                onChanged: (direction) => setState(() => _activeTab = direction),
              ),
              const SizedBox(height: 16,),
              Expanded(
                child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF258CFA)),)
                  : _rows.isEmpty
                    ? const Center(child: Text('No history yet', style: TextStyle(color: Colors.white38))
                )
                : ListView(
                  children: _dateGrouping.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ...entry.value.map((row) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildRow(row)
                        )
                        ),
                        const SizedBox(height: 8)
                      ],
                    );
                  }).toList(),
                )
              ),

              if (_selectionMethod && _selectedItemIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  onPressed: _deleteSelectedHistory,
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  label: Text('Delete (${_selectedItemIds.length})'),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF258CFA),
                  minimumSize: const Size.fromHeight(48)
                  )
                )
              )
            ]
          ),
        )
    )
    );
  }

  Widget _buildRow(Map<String, dynamic> row) {
    final String id = row['id'] as String;
    final String fileName = row['fileName'] as String;
    final String mimeType = row['mimeType'] as String;
    final int totalBytes = row['totalBytes'] as int;
    final String? savedPath = row['savedAt'] as String?;
    final String status = row['transferStatus'] as String;

    final bool fileExists = savedPath != null && File(savedPath).existsSync();
    final bool isFailed = status == TransferStatus.failed.name;

    String? statusLabel;
    Color? statusColor;
    if (isFailed) {
      statusLabel = 'Failed';
      statusColor = Colors.redAccent;
    } else if (!fileExists) {
      statusLabel = 'File not found';
      statusColor = Colors.redAccent;
    }

    Widget trailing;
    if (_selectionMethod) {
      trailing = Checkbox(
        value: _selectedItemIds.contains(id),
        onChanged: (_) => _toggleSelected(id),
        activeColor: const Color(0xFF258CFA),
      );
    } else if (!fileExists) {
      trailing = GestureDetector(
        onTap: () => _toggleSelected(id),
        child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 22)
      );
    } else if (mimeType.startsWith('audio/') || mimeType.startsWith('video/')) {
      trailing = TextButton(
        onPressed: () {
          // To implement opening file using open_file_package
        }, 
        child: const Text('Play', style: TextStyle(color: Color(0xFF258CFA), fontSize: 12))
      );
    } else {
      trailing = const SizedBox.shrink();
    }

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _selectionMethod = true;
          _selectedItemIds.add(id);
        });
      },
      child: FileTransferTile(
        data: TransferTile(
          id: id, 
          fileName: fileName, 
          icon: _icon(mimeType), 
          sizeLabel: _byteFormat(totalBytes), 
          trailing: trailing,
          statusLabel: statusLabel,
          statusColor: statusColor,
      )
    )
    );
  }

}