// Blueprint for a single file.
class IncomingFile{
  final String fileId;
  final String name;
  final String mimeType;
  final int size;
  const IncomingFile({
    required this.fileId,
    required this.name,
    required this.mimeType,
    required this.size
  });
  // Translates the raw text data to a clean dart object that the app can understand.
  factory IncomingFile.fromJson(Map<String,dynamic> json) {
    return IncomingFile(
      fileId: json['fileId'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
      mimeType: json['mimeType'] as String,
    );
  }
}