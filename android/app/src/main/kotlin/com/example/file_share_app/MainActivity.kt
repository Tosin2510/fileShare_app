package com.example.file_share_app
// Packages used to bring in tools built by Android and Flutter
import android.content.pm.PackageManager // Access installed apps on android
import io.flutter.embedding.android.FlutterActivity // The android activity that hosts the flutter app
import io.flutter.embedding.engine.FlutterEngine // 
import io.flutter.plugin.common.MethodChannel // Lets android and flutter talk to each other

class MainActivity : FlutterActivity() {
  // Flutter sends a message over this channel.
  private val CHANNEL = "com.example.file_share_app/apk_path"

// This actually configures the flutter engine when the application starts running.
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    // This MethodChannel basically listens to incoming calls from flutter
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
       .setMethodCallHandler { call, result -> 
       // This one check if the incoming call from flutter is getAPK
          if(call.method == "getApkPath") {
            val packageName = call.argument<String>("packageName") // This basically extracts the package name from flutter. 
            try{
              // This query the AndroidPackage manager and assumes that the packageManager flutter is sending is not null
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