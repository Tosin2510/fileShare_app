import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_share_app/features/file_transfer/services/outgoing_file.dart';
import 'package:mime/mime.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class OutgoingFileConverter {
  static int _counter = 0;
  static String _nextId() => 'file_${DateTime.now().millisecondsSinceEpoch}_${_counter++}';

  // This converts picked files(general files)

  static OutgoingFile fromPlatformFile(PlatformFile file) {
    final mimeType = lookupMimeType(file.name) ?? 'application/octet-stream';
    return OutgoingFile(
      fileId: _nextId(),
      name: file.name,
      mimeType: mimeType,
      size: file.size,
      path: file.path!,
    );
  }
  // Converts picked media files,

  static Future<OutgoingFile?> fromAssetEntity(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file == null) return null;

    final String name = asset.title ?? file.path.split('/').last;
    final mimeType = asset.mimeType ?? lookupMimeType(name) ?? 'application/octet-stream';
    final int size = await file.length();

    return OutgoingFile(
      fileId: _nextId(),
      name: name,
      mimeType: mimeType,
      size: size,
      path: file.path,
      );
  }

static Future<List<OutgoingFile>> convertAll({
  List<PlatformFile> platformFiles = const [],
  List<AssetEntity> mediaFiles = const [],
}) async {
  final List<OutgoingFile> result = [];

  result.addAll(platformFiles.map(fromPlatformFile));

  for (final asset in mediaFiles) {
    final converted = await fromAssetEntity(asset);
    if (converted != null) result.add(converted);
  }

  return result;
}
}