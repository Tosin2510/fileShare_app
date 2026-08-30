import 'package:file_share_app/features/app_management/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// Basically lets users select image and video files from their devices.
class MediaPickerService{
  final PermissionService _permissionService = PermissionService();
  Future<List<AssetEntity>?> pickMediaFiles(BuildContext context) async { // The future can return null or am AssetEntity
  try{
    final bool hasAccess = await _permissionService.requestMediaPermission();
    if(!hasAccess) return null;
    if(!context.mounted) return null;
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,         
      pickerConfig: AssetPickerConfig(
        maxAssets: 500, //Sets file picking limit to 500 
        requestType: RequestType.common, //For images and videos
        textDelegate: EnglishAssetPickerTextDelegate(),
        themeColor: Color(0xFF258CF4),
        gridThumbnailSize: const ThumbnailSize.square(100), 
      )
    );
    if(!context.mounted ) return null;
    return result;
  } catch(e) {
    debugPrint("Error inside Media Picker Service $e");
    return null;
  }
  }
}