import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String geminiResponse = "";

  Future<void> _processImageAndSendToPython(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      print("Selected file path: ${file.path}");

      setState(() {
        if (kIsWeb) {
          if (file.bytes != null) {
            currentWidgetBeingDisplayed = Column(
              children: [
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 500, maxWidth: 500),
                  child: Image.memory(file.bytes!, fit: BoxFit.contain),
                ),
                const SizedBox(height: 5),
                const Text("Sending image..."),
              ],
            );
          } else if (file.path != null) {
            currentWidgetBeingDisplayed = Column(
              children: [
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 500, maxWidth: 500),
                  child: Image.network(file.path!, fit: BoxFit.contain),
                ),
                const SizedBox(height: 5),
                const Text("Sending image..."),
              ],
            );
          } else {
            currentWidgetBeingDisplayed = const Text("Could not display image");
            geminiResponse = "Could not display image";
          }
        } else {
          currentWidgetBeingDisplayed = Column(
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 500, maxWidth: 500),
                child: Image.file(
                  File(file.path!),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 5),
              const Text("Sending image..."),
            ],
          );
        }
      });

      try {
        final response = await _sendImageToPython(file);
        if (response != null) {
          // Print the response to the terminal
          print("Gemini Response: ${response['extracted_text']}");
        }
      } catch (e) {
        print("Error sending image: $e");
        setState(() {
          geminiResponse = "Error: $e";
          currentWidgetBeingDisplayed = Column(
            children: [
              currentWidgetBeingDisplayed,
              const SizedBox(height: 20),
              Text("Error sending image: $e"),
            ],
          );
        });
      }
    } else {
      print("User canceled file picking");
      setState(() {
        currentWidgetBeingDisplayed = const Text("User canceled file picking");
        geminiResponse = "User canceled";
      });
    }
  }

  Future<Map<String, dynamic>?> _sendImageToPython(PlatformFile file) async {
    const url = 'http://127.0.0.1:5000/process_poster';

    try {
      // Read file data
      List<int> imageBytes;
      if (kIsWeb) {
        if (file.bytes != null) {
          imageBytes = file.bytes!;
        } else {
          throw Exception("File has no data");
        }
      } else {
        imageBytes = await File(file.path!).readAsBytes();
      }

      // Encode to base64
      String base64Image = base64Encode(imageBytes);

      // Create request
      var request = http.Request('POST', Uri.parse(url));
      request.bodyFields = {
        'image_data': base64Image,
      };

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = json.decode(responseBody);
        print('Response from Python: $decodedResponse');
        if (decodedResponse['status'] == 'success') {
          return decodedResponse;
        } else {
          setState(() {
            geminiResponse = 'Error from Python: ${decodedResponse['error']}';
          });
          return null;
        }
      } else {
        setState(() {
          geminiResponse =
              'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
        print(
            'Error sending image: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      setState(() {
        geminiResponse = 'Exception: $e';
      });
      print('Exception sending image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _processImageAndSendToPython(context),
                  child: const Text("Select Image and Send to Python"),
                ),
                const SizedBox(height: 20),
                currentWidgetBeingDisplayed,
                // Removed Text("Response: $geminiResponse"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
