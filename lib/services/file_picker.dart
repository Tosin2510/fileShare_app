import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
class FilePickerService {
  static Future<List<PlatformFile>> pickFiles(String fileCategory) async {
    try{
      FileType type = FileType.any;
      List<String>? allowedExtensions;
      switch (fileCategory) {
        case 'Images': type = FileType.image; break;
        case 'Videos': type = FileType.video; break;
        case 'Music': type = FileType.audio; break;
        case 'Files': type = FileType.any; break;
        case 'Apps':
        type = FileType.custom;
        allowedExtensions = ['apk']; break;
        default: type = FileType.any;
      }
      FilePickerResult? result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: false,
      );
      if (result != null) {
        return result.files.where((file) => file.path != null).toList();
      }
      return [];
      } catch (e) {
        debugPrint('Error picking files: $e');
     }
     return [];
  } 
}