import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/poster_details.dart';
import '../services/api_service.dart';
import '../services/gpt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final GptService _gptService = GptService();
  final ImagePicker _picker = ImagePicker();

  List<PosterDetails> _events = [];
  bool _isLoading = true;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _apiService.getAllPosters();
      
      // Sort events by date and time
      events.sort((a, b) {
        int dateComp = a.date.compareTo(b.date);
        if (dateComp != 0) return dateComp;
        return a.time.compareTo(b.time);
      });

      setState(() {
        _events = events;
      });
    } catch (e) {
      debugPrint("Error fetching events: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAndProcessPoster() async {
    try {
      // CHANGED: Using ImageSource.gallery opens the desktop file picker on Flutter Web
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return; // User canceled the file picker

      setState(() => _isProcessingImage = true);

      // Send the uploaded file to GPT API to extract text & format into object
      final extractedDetails = await _gptService.extractDetailsFromImage(image);

      // Log into database via FastAPI
      await _apiService.addPoster(extractedDetails);

      // Refresh the list to show the newly sorted event
      await _fetchEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event successfully logged!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error processing poster: $e')),
        );
      }
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEvents,
          )
        ],
      ),
      body: _isProcessingImage
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("AI is analyzing the uploaded poster..."),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _events.isEmpty
                  ? const Center(child: Text("No events found. Upload a poster to get started!"))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              event.eventName, 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${event.date} at ${event.time}'),
                                const SizedBox(height: 4),
                                Text(event.location),
                                const SizedBox(height: 4),
                                Text(event.details, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                if (event.id != null) {
                                  await _apiService.deletePoster(event.id!);
                                  _fetchEvents();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadAndProcessPoster,
        icon: const Icon(Icons.upload_file), // Updated icon
        label: const Text("Upload Poster"),  // Updated text
      ),
    );
  }
}