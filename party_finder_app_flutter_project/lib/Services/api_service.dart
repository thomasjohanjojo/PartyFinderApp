import 'dart:convert';
import 'package:http/http.dart' as http;
import 'party_finder_app_flutter_project\lib\Models\poster_details.dart';

class ApiService {
  // Replace actual FastAPI server URL. 
  // If running locally, use 'http://localhost:8000' or your specific port.
  static const String baseUrl = 'http://127.0.0.1:8000';

  // GET /posters
  Future<List<PosterDetails>> getAllPosters() async {
    final response = await http.get(Uri.parse('$baseUrl/posters'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => PosterDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posters: ${response.statusCode}');
    }
  }

  // POST /posters
  Future<PosterDetails> addPoster(PosterDetails poster) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posters'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(poster.toJson()),
    );

    if (response.statusCode == 201) {
      return PosterDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add poster: ${response.statusCode}');
    }
  }

  // DELETE /posters/{posterID}
  Future<void> deletePoster(String posterId) async {
    final response = await http.delete(Uri.parse('$baseUrl/posters/$posterId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete poster: ${response.statusCode}');
    }
  }
}