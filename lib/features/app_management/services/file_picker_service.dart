import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

//  Alows users to select audio and other file type from their device...
class FilePickerService {
  static Future<List<PlatformFile>> pickFiles(String fileCategory) async {
    try{
      FileType type = FileType.any;
      switch (fileCategory) { 
        case 'Music': type = FileType.audio; break;
        case 'Files': type = FileType.any; break;
      }
      // For the app picker, this part defines what is possible to select.
      FilePickerResult? result = await FilePicker.pickFiles(
        type: type,
        allowMultiple: true,
        withData: false
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