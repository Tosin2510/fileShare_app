import 'package:file_share_app/features/app_management/services/app_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
class AppPickerScreen extends StatefulWidget{
  const AppPickerScreen({super.key});
  @override
  State<AppPickerScreen> createState() => _AppPickerScreenState();
}
class _AppPickerScreenState extends State<AppPickerScreen> {
   List<AppInfo> apps = []; 
   final Map<String, String> selectedApps = {};
   bool isLoading = true;
   
   @override
   void initState() {
    super.initState();
    loadApps();
   }
   Future<void> loadApps() async {
    final apps = await AppPickerService.getInstalledApps();
    if(!mounted) return;
    setState(() {
      this.apps = apps;
      isLoading = false;
    }
    );
   }
  

   void controlSelection(AppInfo app) {
    setState(() {
      if(selectedApps.containsKey(app.packageName)) {
        selectedApps.remove(app.packageName);
      }
      else{
        selectedApps[app.packageName] = app.name;
      }
    });
   }

   @override
   Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Select Apps", 
        style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          if(selectedApps.isNotEmpty)
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedApps);
            },
            child: Text(
              "Select ${selectedApps.length}",
              style: const TextStyle(color: Color(0xFF258CF4))
            )
            )
        ],
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator())

      : ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          final isSelected = selectedApps.containsKey(app.packageName);
          return ListTile(
            leading: FutureBuilder<AppInfo?>(
              future: InstalledApps.getAppInfo(app.packageName),
              builder: (context, snapshot) {
                final icon = snapshot.data?.icon;
                if (icon != null) {
                  return Image.memory(icon, width: 38, height: 38);
                }
                return const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(Icons.android, color: Colors.white24),
                );
              }
            ),
             title: Text(
              app.name,
              style: const TextStyle(color: Colors.white),
             ),
             subtitle: Text(
              app.packageName,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              overflow: TextOverflow.ellipsis,
              ),
              trailing: isSelected
              ? const Icon(Icons.check_circle, color: Color(0xFF258CFA))
              : const Icon(Icons. circle_outlined, color: Colors.grey),
              onTap: () => controlSelection(app),
            );
        }
            )   
            );
        } 
   }

