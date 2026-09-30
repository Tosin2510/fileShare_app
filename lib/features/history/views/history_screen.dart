import 'dart:io';

import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:file_share_app/features/file_transfer/models/transfer_tile.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_history.dart';
import 'package:file_share_app/features/file_transfer/widgets/file_transfer_tile.dart';
import 'package:file_share_app/features/file_transfer/widgets/tab_toggle_direction.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransferDirection activeTab = TransferDirection.received;
  bool loading = true;
  List<Map<String, dynamic>> hist = [];
  bool selectionMethod = false;
  final Set<String> selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final rows = await TransferHistoryService.instance.getAllTransferHistory();
    if (mounted) {
      setState(() {
        loading = false;
        hist = rows;
      });
    }
  }

  List<Map<String, dynamic>> get rows => hist
      .where((r) => r['transferDirection'] == activeTab.name)
      .toList();

  Map<String, List<Map<String, dynamic>>> get _dateGrouping {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final row in rows) {
      final timeStamp = row['timeStamp'] as int;
      final date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
      final dateLabel = dateHeader(date);
      groups.putIfAbsent(dateLabel, () => []).add(row);
    }
    return groups;
  }

  void _toggleSelected(String id) {
    setState(() {
      if (selectedItemIds.contains(id)) {
        selectedItemIds.remove(id);
      } else {
        selectedItemIds.add(id);
      }
    });
  }

  IconData icon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType.startsWith('video/')) return Icons.videocam_rounded;
    if (mimeType.startsWith('audio/')) return Icons.music_note_rounded;
    if (mimeType == 'application/vnd.android.package-archive/') return Icons.android_rounded;
    return Icons.insert_drive_file_rounded;
  }

  String byteFormat(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes/ (1024 * 1024)).toStringAsFixed(2)}MB';
    if (bytes >= 1024) return '${(bytes/ 1024).toStringAsFixed(2)}KB';
    return '${bytes}B';
  }

// Users can choose to delect whatever history they choose.
  Future<void> deleteSelectedHistory() async {
    await TransferHistoryService.instance.deleteTransferHistory(selectedItemIds.toList());
    setState(() {
      selectedItemIds.clear();
      selectionMethod = false;
    });
    await loadHistory();
  }

  String dateHeader(DateTime date) {
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
              // For the received and sent history.
              TabToggleDirection(
                active: activeTab,
                onChanged: (direction) => setState(() => activeTab = direction),
              ),
              const SizedBox(height: 16,),
              Expanded(
                child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF258CFA)),)
                  : rows.isEmpty
                    ? const Center(child: Text('No history yet', style: TextStyle(color: Colors.white38))
                )
                // The listview is used for easy scrolling.
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
                          child: buildRow(row)
                        )
                        ),
                        const SizedBox(height: 8)
                      ],
                    );
                  }).toList(),
                )
              ),
              if (selectionMethod && selectedItemIds.isNotEmpty)    
              if (selectionMethod && selectedItemIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  onPressed: deleteSelectedHistory,
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  label: Text('Delete (${selectedItemIds.length})'),
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

  Widget buildRow(Map<String, dynamic> row) {
    final String id = row['id'] as String;
    final String fileName = row['fileName'] as String;
    final String mimeType = row['mimeType'] as String;
    final int totalBytes = row['totalBytes'] as int;
    final String? savedPath = row['savedAt'] as String?;
    final String status = row['transferStatus'] as String;

    final bool fileExists = savedPath != null && (savedPath.startsWith('content://') || File(savedPath).existsSync());
    final bool isFailed = status == TransferStatus.failed.name;

    String? statusLabel;
    Color? statusColor;
    if (isFailed) {
      statusLabel = 'Failed';
      statusColor = Colors.redAccent;
    } else if (!fileExists) {
      statusLabel = 'File can\'t be opened here, check your device.';
      statusColor = Colors.redAccent;
    }
    Widget trailing;
    if (selectionMethod) {
      trailing = Checkbox(
        value: selectedItemIds.contains(id),
        onChanged: (_) => _toggleSelected(id),
        activeColor: const Color(0xFF258CFA),
      );
    } else if (!fileExists) {
      trailing = GestureDetector(
        onTap: () => _toggleSelected(id),
        child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 22)
      );
    } else {
      trailing = IconButton(
        onPressed: () async {
            final outcome = await OpenFile.open(savedPath);
            if (outcome.type != ResultType.done && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not open file: ${outcome.message}'),
                )
              );
          }
        },
        icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF258CFA), size: 20)
      );
    }
    return GestureDetector(
      onLongPress: () {
        setState(() {
          selectionMethod = true;
          selectedItemIds.add(id);
        });
      },
      child: FileTransferTile(
        data: TransferTile(
          id: id, 
          fileName: fileName, 
          icon: icon(mimeType), 
          sizeLabel: byteFormat(totalBytes), 
          trailing: trailing,
          statusLabel: statusLabel,
          statusColor: statusColor,
      )
    )
    );
  }

}