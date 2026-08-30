import 'dart:io';

import 'package:file_share_app/features/app_management/services/apk_path_service.dart';
import 'package:file_share_app/features/app_management/services/file_picker_service.dart';
import 'package:file_share_app/features/app_management/services/media_picker_service.dart';
import 'package:file_share_app/features/app_management/views/app_picker_screen.dart';
import 'package:file_share_app/features/device_discovery/views/device_list.dart';
import 'package:file_share_app/features/file_transfer/widgets/send_selection_button.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  int _totalByteSize = 0;
  String selectedIconButton = 'Images';
  List<PlatformFile> selectedFile = [];
  final MediaPickerService _mediaPickerService = MediaPickerService();
  List<AssetEntity> selectedMediaFile = [];
  final List<int> _mediaByteSizes = [];
  bool _isLoading = false;
  // Colors from my figma design.
  final Color activeTabBackground = const Color(0xFF258CF4);
  final Color inactiveTabBackground = const Color(0xFF1F1F1F);
  final Color inactiveTabText = const Color(0XFFFFFFFF);
  // This is for the file picking logic.
  Future<void> _pickMediaFiles() async{
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try{
      final List<AssetEntity>? mediaFiles = await _mediaPickerService.pickMediaFiles(context);
      if(!mounted) return;
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        final unselected = mediaFiles.where(
          (val) => !selectedMediaFile.any((v) => v.id == val.id)
        ).toList();
        
        final results = await Future.wait(unselected.map((mediaFiles) async {
          final fileInfo = await mediaFiles.file;
          final size = fileInfo != null ? await fileInfo.length() : 0;
          return MapEntry(mediaFiles, size);
        }));

        if (!mounted) return;
        setState(() {
          for (final entry in results) {
            selectedMediaFile.add(entry.key);
            _mediaByteSizes.add(entry.value);
            _totalByteSize += entry.value;
          }
        });
      }
    } catch(e) {
      debugPrint("Error handling media selection $e");
    } finally{
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void>  _pickFiles(String fileCategory) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try{
      final List<PlatformFile> files = await FilePickerService.pickFiles(fileCategory);
      if(!mounted) return;
      if (files.isNotEmpty) {
        final List<PlatformFile> newFiles = [];
        int addedBytes = 0;
        for (final file in files) {
          final bool isAlreadySelected = selectedFile.any((selected) => selected.path == file.path);
          if (!isAlreadySelected) {
            newFiles.add(file);
            addedBytes += file.size;
          }
        }
        if (!mounted) return;
        setState(() {
          selectedFile.addAll(newFiles);
          _totalByteSize += addedBytes;
        });
      }
    } catch(e) {
      debugPrint("Error handling general file selection");
    } finally{
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                      buttonRep: "Apps",
                      icon: Icons.grid_view_rounded, 
                      containerSize: containerSize,
                      isActive: selectedIconButton == 'Apps',
                      activeTabBackground: activeTabBackground,
                      inactiveTabBackground: inactiveTabBackground,
                      inactiveTabText: inactiveTabText,
                      onTap: () async {
                        setState(() => selectedIconButton = 'Apps');
                        final Map<String, String>? appSelection = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppPickerScreen(),                            
                          ),
                        );
                          if (!mounted) return;
                          if (appSelection != null && appSelection.isNotEmpty) {
                            for (final entry in appSelection.entries) {
                              final String packageName = entry.key;
                              final String app = entry.value;
                              final String? apkPath = await ApkPathService.getApkPath(packageName);
                              if (apkPath == null) continue; // Skip this step if the Apk path is not found.
                              final appAvailable = selectedFile.any((b) => b.path == apkPath);
                              if(!appAvailable) {
                                final int sizeInBytes = await File(apkPath).length();
                                setState(() {
                                  selectedFile.add(
                                    PlatformFile(
                                      name: '$app.apk',
                                      path: apkPath,
                                      size: sizeInBytes,
                                    )
                                    );
                                    _totalByteSize += sizeInBytes;
                                });
                              }
                            } 
                          }
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
                      buttonRep: 'Media',
                      icon: Icons.image,
                      containerSize: containerSize,
                      isActive: selectedIconButton == 'Media',
                      activeTabBackground: activeTabBackground,
                      inactiveTabBackground: inactiveTabBackground,
                      inactiveTabText: inactiveTabText,
                      onTap: () async {
                        setState(() {
                          selectedIconButton = 'Media';
                        });
                        await _pickMediaFiles();
                      },
                    ),
                  ],
                ),
              ),

              // This section shows if files have been selected as well as the size of the selected files.
              if (selectedFile.isNotEmpty || selectedMediaFile.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Starts a counter at 0 and adds the size oif every file in the selected file list to get the size in Mb to 2 decimal places.
                        "${selectedFile.length + selectedMediaFile.length} Files • ${(_totalByteSize / (1024 * 1024)).toStringAsFixed(2)} MB",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: containerSize * 0.06,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          selectedFile.clear();
                          selectedMediaFile.clear();
                          _mediaByteSizes.clear();
                          _totalByteSize = 0;
                          }),
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
                      : selectedFile.isEmpty && selectedMediaFile.isEmpty
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
                        itemCount: selectedFile.length + selectedMediaFile.length,
                        itemBuilder: (context, index) {
                          final bool isGeneralFile = index < selectedFile.length;
                          String displayName = '';
                          double itemSizeInBytes = 0;
                          IconData leadingIcon = Icons.insert_drive_file_rounded;
                          if(isGeneralFile) {
                            final file = selectedFile[index];
                            displayName = file.name;
                            itemSizeInBytes = file.size.toDouble();
                            leadingIcon = Icons.insert_drive_file_rounded;
                          } else{
                            final mediaIndex = index - selectedFile.length;
                            final mediaFile = selectedMediaFile[mediaIndex];
                            displayName = mediaFile.title?? "Media File";
                            itemSizeInBytes = _mediaByteSizes[mediaIndex].toDouble(); // Will be handled dynamically below
                            leadingIcon = mediaFile.type == AssetType.video
                            ? Icons.video_collection_rounded:
                            Icons.image_rounded;
                          }
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
                                  leadingIcon,
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
                                        displayName,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: containerSize * 0.065,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if(itemSizeInBytes > 0)
                                      Text(
                                        // This displays the file size. If the file size is greater than 1 Mb, it will display the size in Mb, otherwise, it will display in Kb to 2 decimal places.
                                        itemSizeInBytes > 1024 * 1024 
                                          ? "${(itemSizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB"
                                          : "${(itemSizeInBytes/ 1024).toStringAsFixed(2)} KB",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: containerSize * 0.045,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    if(isGeneralFile) {
                                      _totalByteSize -= selectedFile[index].size;
                                      selectedFile.removeAt(index);
                                    } else{
                                      final mediaIndex = index - selectedFile.length;
                                      _totalByteSize -= _mediaByteSizes[mediaIndex];
                                      selectedMediaFile.removeAt(mediaIndex);
                                      _mediaByteSizes.removeAt(mediaIndex);                 
                                      }
                                  }),
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
                if (selectedFile.isNotEmpty || selectedMediaFile.isNotEmpty)
                  Positioned(
                    // Using a percentage of screen width for horizontal padding
                    left: MediaQuery.of(context).size.width * 0.04, 
                    right: MediaQuery.of(context).size.width * 0.04,
                    // Using a percentage of height to stay consistently above the bottom nav
                    bottom: MediaQuery.of(context).padding.bottom + (MediaQuery.of(context).size.height * 0.02),                    
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFF1E1E24),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24))
                          ),
                          builder: (_) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.4,
                            maxChildSize: 0.92,
                            expand: false,
                            builder:(_, scrollController) => DeviceListScreen(
                              selectedFiles: selectedFile,
                              selectedMediaFiles: selectedMediaFile,
                              onTransferComplete: () {
                                setState(() {
                                  selectedFile.clear();
                                  selectedMediaFile.clear();
                                  _mediaByteSizes.clear();
                                  _totalByteSize = 0;
                                });
                              }
                            )
                          ),
                        );
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
                            "Send ${selectedFile.length + selectedMediaFile.length} files",
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