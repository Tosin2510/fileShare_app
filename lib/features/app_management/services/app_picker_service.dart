import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
class AppPickerService{
  static Future<List<AppInfo>> getInstalledApps() async {
    return await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      excludeNonLaunchableApps: true,
      withIcon: false,
      );
  }
}