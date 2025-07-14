import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview/db/database_helper.dart';
import 'package:webview/widgets/common_appbar.dart';
import 'package:webview/widgets/common_drawer.dart';
import 'package:share_plus/share_plus.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<FileSystemEntity> imageFiles = [];
  List<FileSystemEntity> selectedFiles = [];
  bool isLoading = true;
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    final pathFromDb = await DatabaseHelper().getSettingValue('download path');

    if (pathFromDb == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Download path not found in settings")),
      );
      setState(() => isLoading = false);
      return;
    }

    final directory = Directory(pathFromDb);
    final files = directory
        .listSync()
        .where(
          (file) =>
              file.path.toLowerCase().endsWith('.png') ||
              file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.jpeg'),
        )
        .toList();

    files.sort((a, b) {
      final aTime = File(a.path).lastModifiedSync();
      final bTime = File(b.path).lastModifiedSync();
      return bTime.compareTo(aTime);
    });

    setState(() {
      imageFiles = files;
      selectedFiles.clear();
      isSelectionMode = false;
      isLoading = false;
    });
  }
  Future<void> deleteSelectedImages() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Delete"),
      content: Text("Are you sure you want to delete ${selectedFiles.length} image(s)?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    for (final file in selectedFiles) {
      if (await File(file.path).exists()) {
        await File(file.path).delete();
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ ${selectedFiles.length} image(s) deleted")),
    );

    loadImages();
  }
}


  void toggleSelection(FileSystemEntity file) {
    setState(() {
      if (selectedFiles.contains(file)) {
        selectedFiles.remove(file);
        if (selectedFiles.isEmpty) isSelectionMode = false;
      } else {
        selectedFiles.add(file);
        isSelectionMode = true;
      }
    });
  }


  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: isSelectionMode ? "${selectedFiles.length} selected" : "Gallery",
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: deleteSelectedImages,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() {
                    selectedFiles.clear();
                    isSelectionMode = false;
                  }),
                ),
              ]
            : [],
      ),
      drawer: isSelectionMode ? null : CommonDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : imageFiles.isEmpty
            ? const Center(child: Text("📂 No images found"))
            : ListView.builder(
                itemCount: imageFiles.length,
                itemBuilder: (context, index) {
                  final file = File(imageFiles[index].path);
                  final fileName = file.path.split('/').last;
                  final modified = file.lastModifiedSync();
                  final isSelected = selectedFiles.contains(imageFiles[index]);

                  return GestureDetector(
                    onLongPress: () => toggleSelection(imageFiles[index]),
                    onTap: () {
                      if (isSelectionMode) {
                        toggleSelection(imageFiles[index]);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullImagePage(imageFile: file),
                          ),
                        ).then((value) {
                          if (value == true) loadImages();
                        });
                      }
                    },
                    child: Card(
                      color: isSelected ? Colors.blue.shade100 : null,
                      child: ListTile(
                        leading: Stack(
                          children: [
                            Image.file(
                              file,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            if (isSelected)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        title: Text(fileName),
                        subtitle: Text(
                          "Last modified: ${formatDate(modified)}",
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class FullImagePage extends StatelessWidget {
  final File imageFile;

  const FullImagePage({super.key, required this.imageFile});

  Future<void> _deleteImage(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (await imageFile.exists()) {
        await imageFile.delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Image deleted")));
      }
      Navigator.pop(context, true);
    }
  }

  Future<void> _shareImage() async {
    if (await imageFile.exists()) {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        //   text: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(imageFile),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 60,
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 28),
              tooltip: "Share Image",
              onPressed: _shareImage,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 30),
              tooltip: "Delete Image",
              onPressed: () => _deleteImage(context),
            ),
          ),
        ],
      ),
    );
  }
}
