import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const RootWidget());
}

class RootWidget extends StatefulWidget {
  const RootWidget({Key? key}) : super(key: key);
  @override
  SelectThePicturePage createState() => SelectThePicturePage();
}

class SelectThePicturePage extends State<RootWidget> {
  Widget currentWidgetBeingDisplayed =
      const Text("Image will be displayed here");

  // Function to open file explorer and display image
  void openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // Important: Get the file data!
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      print("Selected file path: ${file.path}");

      setState(() {
        if (kIsWeb) {
          // Web: Use Image.memory with the file bytes.
          if (file.bytes != null) {
            currentWidgetBeingDisplayed = ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500, maxWidth: 500),
              child: Image.memory(file.bytes!, fit: BoxFit.contain),
            );
          } else if (file.path != null) {
            currentWidgetBeingDisplayed = ConstrainedBox(
              // Use ConstrainedBox
              constraints: const BoxConstraints(maxHeight: 500, maxWidth: 500),
              child: Image.network(file.path!, fit: BoxFit.contain),
            );
          } else {
            currentWidgetBeingDisplayed = const Text("Could not display image");
          }
        } else {
          // Mobile (Android/iOS): Use Image.file with the file path.
          currentWidgetBeingDisplayed = ConstrainedBox(
            // Use ConstrainedBox
            constraints: const BoxConstraints(
                maxHeight: 500, maxWidth: 500), // Set max height and width
            child: Image.file(File(file.path!),
                fit: BoxFit.contain), // Use BoxFit.contain
          );
        }
      });
    } else {
      // User canceled the picker
      print("User canceled file picking");
      setState(() {
        currentWidgetBeingDisplayed = const Text("User canceled file picking");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // Added Scaffold for better layout
        body: Center(
          // Centered the content
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centered vertically
              children: <Widget>[
                ElevatedButton(
                  onPressed: openFileExplorer,
                  child: const Text("Select Image"),
                ),
                const SizedBox(height: 20), // Added some spacing
                currentWidgetBeingDisplayed, //  Use directly
              ],
            ),
          ),
        ),
      ),
    );
  }
}
