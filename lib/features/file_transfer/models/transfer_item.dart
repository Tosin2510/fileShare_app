enum TransferDirection {sent, received}
enum TransferStatus {waiting, inProgress, paused, done, failed}

// Handles which item is sent or received.
class TransferItem {
  final String id;
  final String fileName;
  final String mimeType;
  final int totalBytes;
  int transferredBytes;
  TransferStatus status;
  final TransferDirection direction;
  String? savedPath;

  TransferItem({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.totalBytes,
    this.transferredBytes = 0,
    this.status = TransferStatus.waiting,
    required this.direction,
    this.savedPath,
   });

   double get progress => totalBytes == 0 ? 0 : transferredBytes/totalBytes;
}