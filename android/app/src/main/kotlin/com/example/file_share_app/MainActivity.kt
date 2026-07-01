package com.example.file_share_app
// Packages used to bring in tools built by Android and Flutter
import android.content.pm.PackageManager // Android internal catalog of installed apps
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel // Lets android and flutter talk to each other

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.example.file_share_app/apk_path"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
       .setMethodCallHandler { call, result -> 
          if(call.method == "getApkPath") {
            val packageName = call.argument<String>("packageName")
            try{
              val appInfo = packageManager.getApplicationInfo(
                packageName!!, PackageManager.GET_META_DATA
              )
              // Sends back the exact path to the base.apk file
              result.success(appInfo.sourceDir)
            } catch(e: Exception) {
              result.error("NOT_FOUND", "APK path not found", null)
            }
          } else{
            result.notImplemented()
          }
       }
  }
}