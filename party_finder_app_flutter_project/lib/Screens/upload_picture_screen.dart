import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
  bool _isLoading = false;
  final String _backendUrl = "http://localhost:8000/posters/extract-from-image";
  String _eventName = "";
  String _eventDateTime = "";
  double _entryFee = 0.0;
  String _eventId = "";
  String _serverMessage = "";

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
              onPressed: _isLoading ? null : _sendToBackend,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Confirm"),
            ), // Yet to be done
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _resetState,
                child: const Text("Retake")), // Yet to be done
          ] else if (doDetailsHaveBeenRetrievedFromAIModelSection) ...[
            const Text("Extracted Poster Details:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.event, color: Colors.blue),
                        title: const Text("Event Name"),
                        subtitle: Text(_eventName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.access_time, color: Colors.green),
                        title: const Text("Date & Time (ISO 8601)"),
                        subtitle: Text(_eventDateTime),
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.attach_money, color: Colors.amber),
                        title: const Text("Entry Fee"),
                        subtitle: Text(_entryFee == 0.0
                            ? "Free"
                            : "\$${_entryFee.toStringAsFixed(2)}"),
                      ),
                      if (_eventId.isNotEmpty)
                        ListTile(
                          leading:
                              const Icon(Icons.fingerprint, color: Colors.grey),
                          title: const Text("Event ID"),
                          subtitle: Text(_eventId),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _resetState,
                child: const Text("Upload Another Poster")),
          ]
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

  Future<void> _sendToBackend() async {
    if (_uploadedPictureData == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _uploadedPictureData!,
        filename: 'uploaded_pic.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          // Match these keys EXACTLY to your Pydantic field names
          _eventId = responseData['id'] ?? "";
          _eventName = responseData['nameOfTheEvent'] ?? "Unknown Event";
          _eventDateTime = responseData['dateAndTime'] ?? "No date provided";

          // Explicitly handle type conversion for safety
          _entryFee = (responseData['entryFee'] as num?)?.toDouble() ?? 0.0;

          _serverMessage = "Data extracted successfully!";
          doPictureHasBeenUploadedSection = false;
          doDetailsHaveBeenRetrievedFromAIModelSection = true;
        });
      } else {
        throw Exception("Server returned error code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _serverMessage = "Network Transmission Error: $e";
        doDetailsHaveBeenRetrievedFromAIModelSection = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetState() {
    setState(() {
      setState(() {
        doShowUploadPicButton = true;
        doPictureHasBeenUploadedSection = false;
        doDetailsHaveBeenRetrievedFromAIModelSection = false;
        _uploadedPictureData = null;
        _serverMessage = "";
        // Clean up data variables
        _eventName = "";
        _eventDateTime = "";
        _entryFee = 0.0;
        _eventId = "";
      });
    });
  }
}
