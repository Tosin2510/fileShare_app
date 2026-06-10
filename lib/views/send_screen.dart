import 'package:file_share_app/services/file_picker.dart';
import 'package:file_share_app/widgets/send_selection_button.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  String selectedIconButton = 'Images';
  List<PlatformFile> selectedFile = []; 
  bool _isLoading = false;
  // Colors from my figma design.
  final Color activeTabBackground = const Color(0xFF258CF4);
  final Color inactiveTabBackground = const Color(0xFF1F1F1F);
  final Color inactiveTabText = const Color(0XFFFFFFFF);

  // This is for the file picking logic.
  Future<void>  _pickFiles(String fileCategory) async {

    if (_isLoading) return; 

    setState(() => _isLoading = true);
    final List<PlatformFile> files = await FilePickerService.pickFiles(fileCategory);
    if (files.isNotEmpty) {
      for (var file in files) {
        bool alreadySelected = selectedFile.any((selected) => selected.path == file.path);
        if (!alreadySelected) {
          setState(() => selectedFile.add(file));
        }
      }
    }
    setState(() => _isLoading = false);
  }

  // Clear cache when leaving to save user storage space.
  @override
  void dispose() {
    FilePicker.clearTemporaryFiles();
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SendSelectionButton(
                      buttonRep: 'Image', 
                      icon: Icons.image,
                      containerSize: containerSize,
                      isActive: selectedIconButton == 'Image',
                      activeTabBackground: activeTabBackground, 
                      inactiveTabBackground: inactiveTabBackground,
                      inactiveTabText: inactiveTabText,
                      onTap: () async {
                        setState(() {
                          selectedIconButton = 'Image';
                        });
                        await _pickFiles('Image');
                      },
                    ),
                    SendSelectionButton(
                      buttonRep: "Apps", 
                      icon: Icons.grid_view_rounded, 
                      containerSize: containerSize,
                      isActive: selectedIconButton == 'Apps',
                      activeTabBackground: activeTabBackground,
                      inactiveTabBackground: inactiveTabBackground,
                      inactiveTabText: inactiveTabText,
                      onTap: () async {
                        setState(() {
                          selectedIconButton = 'Apps';
                        });
                        await _pickFiles('Apps');
                      },
                    ),
                    SendSelectionButton(
                      buttonRep: "Music", 
                      icon: Icons.music_note_outlined, 
                      containerSize: containerSize,
                      isActive: selectedIconButton == 'Music',
                      activeTabBackground: activeTabBackground,
                      inactiveTabBackground: inactiveTabBackground,
                      inactiveTabText: inactiveTabText,
                      onTap: () async {
                        setState(() {
                          selectedIconButton = 'Music';
                        });
                        await _pickFiles('Music');
                      },
                    ),
                    SendSelectionButton(
                      buttonRep: "Files", 
                      icon: Icons.description_outlined, 
                      containerSize: containerSize,
                      isActive: selectedIconButton == 'Files',
                      activeTabBackground: activeTabBackground,
                      inactiveTabBackground: inactiveTabBackground,
                      inactiveTabText: inactiveTabText,
                      onTap: () async {
                        setState(() {
                          selectedIconButton = 'Files';
                        });
                        await _pickFiles('Files');
                      },
                    ),
                    SendSelectionButton(
                      buttonRep: "Videos", 
                      icon: Icons.videocam_outlined, 
                      containerSize: containerSize,
                      isActive: selectedIconButton == 'Videos',
                      activeTabBackground: activeTabBackground,
                      inactiveTabBackground: inactiveTabBackground,
                      inactiveTabText: inactiveTabText,
                      onTap: () async {
                        setState(() {
                          selectedIconButton = 'Videos';
                        });
                        await _pickFiles('Videos');
                      },
                    ),
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
}