import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class UploadPictureWidget extends StatefulWidget {
  const UploadPictureWidget({super.key});
  @override
  State<UploadPictureWidget> createState() {
    return _UploadPictureWidgetState();
  }
}

class _UploadPictureWidgetState extends State<UploadPictureWidget> {
  bool doShowUploadPicButton = true;
  bool doPictureHasBeenUploadedSection = false;
  bool doDetailsHaveBeenRetrievedFromAIModelSection = false;
  Uint8List? _uploadedPictureData;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (doShowUploadPicButton) ...[
            ElevatedButton(
                onPressed: _uploadPicture, child: Text("Upload Pic")),
          ] else if (doPictureHasBeenUploadedSection) ...[
            SizedBox(
              height: 500,
              width: 500,
              child: Image.memory(_uploadedPictureData!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {}, child: Text("Confirm")), // Yet to be done
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {}, child: Text("Retake")), // Yet to be done
          ] else if (doDetailsHaveBeenRetrievedFromAIModelSection)
            ...[]
        ],
      ),
    );
  }

  Future<void> _uploadPicture() async {
    doShowUploadPicButton = false;
    FilePickerResult? filePickerResult = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);

    if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
      setState(() {
        _uploadedPictureData = filePickerResult.files.first.bytes;
        doPictureHasBeenUploadedSection = true;
      });
    }
  }
}
