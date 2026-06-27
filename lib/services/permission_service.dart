import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
class PermissionService{
  Future<bool> requestMediaPermission() async {
    try{
    final PermissionState permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission:AndroidPermission(
          type: RequestType.common,
          mediaLocation: true)
      )
    );
    return permission.hasAccess; 
    } catch(e) {
      debugPrint("Error inside permission service $e");
      return false;
    }
  }
}