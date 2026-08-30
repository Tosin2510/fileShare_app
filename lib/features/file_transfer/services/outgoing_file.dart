// This model handles a file that is being sent to another device.
class OutgoingFile {
  final String fileId;
  final String name;
  final String mimeType;
  final int size;
  final String path;

  const OutgoingFile({
    required this.fileId,
    required this.name,
    required this.mimeType,
    required this.size,
    required this.path,
  });
  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'name': name,
    'mimeType': mimeType,
    'size': size,
  };
}