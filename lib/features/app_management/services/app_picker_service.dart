import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
class AppPickerService{
  // Gets the list of installed apps on the device but does not include system apps and non-launchable apps.
  static Future<List<AppInfo>> getInstalledApps() async {
    return await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      excludeNonLaunchableApps: true,
      withIcon: false,
      );
  }
}