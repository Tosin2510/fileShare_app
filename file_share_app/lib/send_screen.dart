import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  String selectedIconButton = 'Images';
  List<PlatformFile> selectedFile = []; // The list of selected files
  bool _isLoading = false; // _isLoading is used to prevent multiple files from opening at the same time.
  // bool _isScanning = false; // Scanning for nearby devices can take a while. 
  
  // Colors from my figma design.
  final Color activeTabBackground = const Color(0xFF258CF4);
  final Color inactiveTabBackground = const Color(0xFF1F1F1F);
  final Color inactiveTabText = const Color(0XFFFFFFFF);

  // This is for the file picking logic.
  Future<void>  _pickFiles(String fileCategory) async {

    if (_isLoading) return; 

    setState(() => _isLoading = true);

    try {
      FileType type = FileType.any; 
      List<String>? allowedExtensions; 
      // Allows different file categories to be selected.
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
      // Flutter basically communicates with the phone's operating system with this. It opens up the file picker.
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true, // This allows the user to pick multiple files.
        withData: false, // Keep it light in case bulky files are involved. This gives the address to the file instead of loading the entire thing into memory.
        lockParentWindow: true, // This prevents the app's user from interacting with the app while the file picker is opened to avoid unexpected behaviour
      );

      if (result != null) {
        setState(() {
          // Check for duplicates before adding
          for (var file in result.files) {
            if (file.path != null) { // This prevent flutter from adding the file to the selected list if the path cannot be found.
              bool isAlreadySelected = selectedFile.any((selected) => selected.path == file.path); // If the file is already selected, the selected file will equate to the file path.
              if (!isAlreadySelected) {
                selectedFile.add(file);
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking files: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Clear cache when leaving to save user storage space.
  @override
  void dispose() {
    FilePicker.platform.clearTemporaryFiles();
    super.dispose();
  }

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
              SizedBox(height: size.height * 0.025),

              // Header: Back and Title
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

              const SizedBox(height: 6),
              Padding(
                padding: EdgeInsets.only(left: containerSize * 0.02),
                child: Text(
                  "Choose what to send.",
                  style: TextStyle(
                    color: const Color(0xFFCCCCCC),
                    fontSize: containerSize * 0.085,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.025),

              // Category Selection Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSendSelectionButton("Images", Icons.image_outlined, containerSize),
                    _buildSendSelectionButton("Apps", Icons.grid_view_rounded, containerSize),
                    _buildSendSelectionButton("Music", Icons.music_note_outlined, containerSize),
                    _buildSendSelectionButton("Files", Icons.description_outlined, containerSize),
                    _buildSendSelectionButton("Videos", Icons.videocam_outlined, containerSize),
                  ],
                ),
              ),

              // This section shows if files have been selected as well as the size of the selected files.
              if (selectedFile.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Starts a counter at 0 and adds the size oif every file in the selected file list to get the size in Mb to 2 decimal places.
                        "${selectedFile.length} Files • ${(selectedFile.fold(0, (sum, file) => sum + file.size) / (1024 * 1024)).toStringAsFixed(2)} MB",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: containerSize * 0.06,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => selectedFile.clear()),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: containerSize * 0.04,
                            vertical: containerSize * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: inactiveTabBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Delete all",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: containerSize * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                    Positioned.fill(
                      child:_isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF258CF4)))
                      : selectedFile.isEmpty
                            ? Center(
                          child: Text(
                            "No files selected",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: containerSize * 0.07,
                            ),
                          ),
                        )
                        : ListView.builder(
                        itemCount: selectedFile.length,
                        itemBuilder: (context, index) {
                          final file = selectedFile[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(containerSize * 0.05),
                            decoration: BoxDecoration(
                              color: inactiveTabBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file_rounded,
                                  color: activeTabBackground,
                                  size: containerSize * 0.12,
                                ),
                                SizedBox(width: containerSize * 0.05),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        // This displays the file name
                                        file.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: containerSize * 0.065,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        // This displays the file size. If the file size is greater than 1 Mb, it will display the size in Mb, otherwise, it will display in Kb to 2 decimal places.
                                        file.size > 1024 * 1024 
                                          ? "${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB"
                                          : "${(file.size / 1024).toStringAsFixed(2)} KB",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: containerSize * 0.045,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => selectedFile.removeAt(index)),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white38,
                                    size: containerSize * 0.08,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
                if (selectedFile.isNotEmpty)
                  Positioned(
                    // Using a percentage of screen width for horizontal padding
                    left: MediaQuery.of(context).size.width * 0.04, 
                    right: MediaQuery.of(context).size.width * 0.04,
                    // Using a percentage of height to stay consistently above the bottom nav
                    bottom: MediaQuery.of(context).padding.bottom + (MediaQuery.of(context).size.height * 0.02),                    child: GestureDetector(
                      onTap: () {
                        // Transfer logic
                      },
                      child: Container(
                        // Height scales with the screen size
                        height: MediaQuery.of(context).size.height * 0.07,
                        constraints: const BoxConstraints(minHeight: 50, maxHeight: 70),
                        decoration: BoxDecoration(
                          color: const Color(0xFF258CF4), // Your verified brand blue
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.035),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Send ${selectedFile.length} files",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              // Font size scales with screen width
                              fontSize: MediaQuery.of(context).size.width * 0.045, 
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ) ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for category buttons
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
                color: isActive ? activeTabBackground : inactiveTabBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha:isActive ? 1.0 : 0.6),
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
      ),
    );
  }
}