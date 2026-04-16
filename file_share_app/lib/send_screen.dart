import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
class SendScreen extends StatefulWidget {
  const SendScreen({super.key});
  @override
  State<SendScreen> createState() => _SendScreenState();
}
class _SendScreenState extends State<SendScreen> {
  Future<void> _pickFiles(String fileCategory) async {
    if (_isLoading) return; // Prevent overlapping file picking...

    setState(() => _isLoading = true);

    try {
      FileType type = FileType.any;
      List<String>? allowedExtensions;

      switch (fileCategory) {
        case 'Images': type = FileType.image; break;
        case 'Videos': type = FileType.video; break;
        case 'Music': type = FileType.audio; break;
        case 'Files': type = FileType.any; break;
        case 'Apps':
          type = FileType.custom;
          allowedExtensions = ['apk'];
          break;
        default: type = FileType.any;
      }

      // This is the part that ensures that the app's file selection part works well even for large files.
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: false, // Only retrieves the path of the selected file instead of the entire file to save memory
        lockParentWindow: true, // This basically ensures that the app works well on desktop devices.
      );

      if (result != null) {
        setState(() {
          // I made use of .addAll so that the users can select files from different category without it affecting their selection from other categories.
          selectedFile.addAll(result.files); 
        });
      }
    } catch (e) {
      debugPrint("Error picking large files: $e");
    } finally {
      // The loading part to false regardless of success or failure
      // This is so that that part closes well and does not cause weird behaviour in the UI.
      setState(() => _isLoading = false);
    }
  }

  String selectedIconButton = 'Images';
  List<PlatformFile> selectedFile = [];
  bool _isLoading = false;
  int activeTabIndex = 0;
  final Color activeTabBackground = const Color(0xFF258CF4);
  final Color inactiveTabBackground = const Color(0xFF1F1F1F);
  final Color inactiveTabText = const Color(0XFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double containerSize = size.width * 0.6;
    return Scaffold(
     backgroundColor: Colors.black, 
     body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Positioned slightly to the top
            SizedBox(height: size.height * 0.025), 

            // 2. Row for Back Icon and "Select Files"
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: containerSize * 0.12, 
                  ),
                ),
                
                // Small gap to nudge title to the right
                SizedBox(width: containerSize * 0.04), 

                Text(
                  "Select Files",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: containerSize * 0.15, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // 3. Subtitle (Bigger and positioned under BOTH)
            const SizedBox(height: 6), 
            Padding(
              // Small padding so it sits somewhat under the back icon
              padding: EdgeInsets.only(left: containerSize * 0.02), 
              child: Text(
                "Choose what to send",
                style: TextStyle(
                  color: const Color(0xFFCCCCCC),
                  fontSize: containerSize * 0.085, // Balanced "bigger" size
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.025),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSendSelectionButton("Images", Icons.image_outlined, containerSize),
                  _buildSendSelectionButton("Apps", Icons.grid_view_rounded, containerSize),
                  _buildSendSelectionButton("Music", Icons.music_note_outlined, containerSize),
                  _buildSendSelectionButton("Files", Icons.description_outlined, containerSize),
                  _buildSendSelectionButton("Videos", Icons.videocam_outlined, containerSize),
                  ]
              ),
            ),
            if (selectedFile.isNotEmpty) 
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // This calculates the length as well as the entire size of the selected files and convert them to MB
                  Text(
                    "${selectedFile.length} Files • ${(selectedFile.fold(0, (sum, file) => sum + file.size) / (1024 * 1024)).toStringAsFixed(1)} MB",
                    style: TextStyle(
                      color: Colors.white70, 
                      fontSize: containerSize * 0.06,
                        ),
                  )],
               ),
              )
          ],
        )
        )
      ),
    );

  }
  Widget _buildSendSelectionButton(String buttonRep, IconData icon, double containerSize) {
    bool isActive = selectedIconButton == buttonRep;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            selectedIconButton = buttonRep;
          });
          await _pickFiles(buttonRep);
        },
        child: Column(
          children: [
            Container(
              width: containerSize * 0.35,
              height: containerSize * 0.35,
              decoration: BoxDecoration(
                color: isActive? activeTabBackground: inactiveTabBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF000000)),

              ),
              child: Center(
                child: Icon(
                  icon,
                  // ICON: 100% white if active, 60% white if inactive
                  color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.6),
                  size: containerSize * 0.14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              buttonRep,
              style: TextStyle(
                color: isActive ? activeTabBackground : inactiveTabText,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      )
      );
  }
}
