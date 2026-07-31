
import 'dart:async';

import 'package:file_share_app/features/file_transfer/models/transfer_item.dart';
import 'package:file_share_app/features/file_transfer/services/transfer_history.dart';

class TransferTracker {
  TransferTracker._internal();
  static final TransferTracker instance = TransferTracker._internal();

  final List<TransferItem> _items = [];
  final StreamController<List<TransferItem>> _controller =
    StreamController<List<TransferItem>>.broadcast();

  Stream<List<TransferItem>> get itemsStream => _controller.stream;
  List<TransferItem> get items => List.unmodifiable(_items);

  void addItem(TransferItem item) {
    _items.add(item);
    _emit();
  }

  void updateProgress(String id, int transferredBytes) {
    final item = _items.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    item.transferredBytes = transferredBytes;
    item.status = TransferStatus.inProgress;
    _emit();
  }
  void markDone(String id, {String? savedPath}) {
    final item = _items.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    item.status = TransferStatus.done;
    item.transferredBytes = item.totalBytes;
    if (savedPath != null) item.savedPath = savedPath;
    _emit();
    TransferHistoryService.instance.recordSharing(item);
  }
  
  void markFailed(String id) {
    final item = _items.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    item.status = TransferStatus.failed;
    _emit();
    TransferHistoryService.instance.recordSharing(item);
  }
  void markPaused(String id) {
    final item = _items.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    item.status = TransferStatus.paused;
    _emit();
  }
  void _emit() => _controller.add(List.from(_items));
}