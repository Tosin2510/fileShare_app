import 'dart:io';

import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:file_share_app/features/file_transfer/models/transfer_tile.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_history.dart';
import 'package:file_share_app/features/file_transfer/widgets/file_transfer_tile.dart';
import 'package:file_share_app/features/file_transfer/widgets/tab_toggle_direction.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

// For the history screen...
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

// This is the loasing of the screen.
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

// This part is to actually group the transfer hist. by date.
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

// Depending on the mime type, we get the correct icon.
  IconData _icon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType.startsWith('video/')) return Icons.videocam_rounded;
    if (mimeType.startsWith('audio/')) return Icons.music_note_rounded;
    if (mimeType == 'application/vnd.android.package-archive/') return Icons.android_rounded;
    return Icons.insert_drive_file_rounded;
  }

// This is for the size in byte of the files in the history screen.
  String _byteFormat(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes/ (1024 * 1024)).toStringAsFixed(2)}MB';
    if (bytes >= 1024) return '${(bytes/ 1024).toStringAsFixed(2)}KB';
    return '${bytes}B';
  }

// Users can choose to delect whatever history they choose.
  Future<void> _deleteSelectedHistory() async {
    await TransferHistoryService.instance.deleteTransferHistory(_selectedItemIds.toList());
    setState(() {
      _selectedItemIds.clear();
      _selectionMethod = false;
    });
    await _loadHistory();
  }

// This shows the date of the transger.
  String _dateHeader(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 
      'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
// The buils.
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
                          child: _buildRow(row)
                        )
                        ),
                        const SizedBox(height: 8)
                      ],
                    );
                  }).toList(),
                )
              ),

              // Checks if the user selects anything, if they do, it shows the delete button.
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

// Thid is the individual row for the transfer history.
  Widget _buildRow(Map<String, dynamic> row) {
    final String id = row['id'] as String;
    final String fileName = row['fileName'] as String;
    final String mimeType = row['mimeType'] as String;
    final int totalBytes = row['totalBytes'] as int;
    final String? savedPath = row['savedAt'] as String?;
    final String status = row['transferStatus'] as String;

// basically checks if the file still exists on the device.
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
    // cONFIRMS IF THE file is on the device still or not.
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
// On long press, the user can choose what to delete.
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