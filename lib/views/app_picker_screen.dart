import 'package:file_share_app/services/app_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
class AppPickerScreen extends StatefulWidget{
  const AppPickerScreen({super.key});
  @override
  State<AppPickerScreen> createState() => _AppPickerScreenState();
}
class _AppPickerScreenState extends State<AppPickerScreen> {
  // As soon as this screen opens, the list of installed apps is fetched and displayed.
   List<AppInfo> _apps = []; // Holds all the installed apps on the device
   final Map<String, String> _selectedApps = {}; // Holds the apps selected by the user.
   bool _isLoading = true;
   
   @override
   void initState() {
    super.initState();
    _loadApps();
   }
   Future<void> _loadApps() async {
    final apps = await AppPickerService.getInstalledApps();
    if(!mounted) return;
    setState(() {
      _apps = apps;
      _isLoading = false;
    }
    );
   }
   // If the user selects an app, it checks if the app is already in the list
   // If it is there already, it removes it from the list. If it is not, it adds it.
   void _controlSelection(AppInfo app) {
    setState(() {
      if(_selectedApps.containsKey(app.packageName)) {
        _selectedApps.remove(app.packageName);
      }
      else{
        _selectedApps[app.packageName] = app.name;
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
        // This action button is visible at the right side of the app bar once the user selects an app.
        actions: [
          if(_selectedApps.isNotEmpty)
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedApps);
            },
            child: Text(
              "Select ${_selectedApps.length}",
              style: const TextStyle(color: Color(0xFF258CF4))
            )
            )
        ],
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
        itemCount: _apps.length,
        itemBuilder: (context, index) {
          final app = _apps[index];
          final isSelected = _selectedApps.containsKey(app.packageName);
          return ListTile(
            leading: app.icon != null
             ? Image.memory(app.icon!, width: 38, height: 38)
             : const Icon(Icons.android, size: 38, color: Colors.white),
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
              onTap: () => _controlSelection(app),
            );
        }
            )   
            );
        } 
   }

