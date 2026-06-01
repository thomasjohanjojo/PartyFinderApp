import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/poster_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  
  Future<PosterDetails> extractDetailsFromImage(XFile imageFile) async {
    // READ THE KEY FROM THE .ENV FILE
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key is missing. Please check your .env file.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey, // Use the retrieved key here
    );

    // Read the image file as bytes (works on both Web and Mobile)
    final imageBytes = await imageFile.readAsBytes();
    
    // Determine the MIME type
    String mimeType = 'image/jpeg';
    if (imageFile.name.toLowerCase().endsWith('.png')) mimeType = 'image/png';
    if (imageFile.name.toLowerCase().endsWith('.webp')) mimeType = 'image/webp';

    // Create the prompt instructing the model to output strict JSON
    final prompt = TextPart('''
Analyze this event poster and extract the following information. 
Return ONLY a valid JSON object with the following keys exactly:
- "event_name": The name of the event.
- "details": A brief description of the event.
- "date": The date of the event in YYYY-MM-DD format. If no specific year is given, assume the current year.
- "time": The time of the event in HH:MM:SS format.
- "location": The location or address of the event.
If any information is completely missing, use an empty string "" for that field.
Do not include markdown formatting like ```json in the output.
''');

    final imagePart = DataPart(mimeType, imageBytes);

    // Send the request to Gemini
    final response = await model.generateContent([
      Content.multi([prompt, imagePart])
    ]);

    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      throw Exception('Gemini API returned an empty response.');
    }

    // Clean up potential markdown formatting in case the model includes it despite instructions
    String cleanJson = responseText.trim();
    if (cleanJson.startsWith('```json')) {
      cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '').trim();
    } else if (cleanJson.startsWith('```')) {
      cleanJson = cleanJson.replaceAll('```', '').trim();
    }

    // Decode the JSON string into your Dart model
    final Map<String, dynamic> jsonMap = json.decode(cleanJson);
    return PosterDetails.fromJson(jsonMap);
  }
}