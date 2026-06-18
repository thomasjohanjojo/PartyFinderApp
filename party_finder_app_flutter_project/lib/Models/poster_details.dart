class PosterDetails {
  final String id;
  final String eventName;
  final String details;
  final String date; // Format: YYYY-MM-DD (Used by UI to sort and display)
  final String time; // Format: HH:MM:SS (Used by UI to sort and display)
  final String location;
  final double entryFee;

  PosterDetails({
    required this.id,
    required this.eventName,
    required this.details,
    required this.date,
    required this.time,
    required this.location,
    this.entryFee = 0.0,
  });

  // Factory constructor: Translates strict backend JSON keys into UI properties
  factory PosterDetails.fromJson(Map<String, dynamic> json) {
    // 1. Split the unified backend 'dateAndTime' string (e.g., "2026-06-18T21:30:00")
    String dateTimeStr = json['dateAndTime'] ?? '';
    List<String> parts = dateTimeStr.split('T');
    String extractedDate = parts.isNotEmpty ? parts[0] : '';
    String extractedTime = parts.length > 1 ? parts[1] : '';

    return PosterDetails(
      id: json['id'] ?? '',
      eventName:
          json['nameOfTheEvent'] ?? '', // Maps backend name to UI property
      date: extractedDate, // Populates local string for UI sorting
      time: extractedTime, // Populates local string for UI sorting
      details: '', // Placeholder (Backend doesn't store this yet)
      location: '', // Placeholder (Backend doesn't store this yet)
      entryFee: (json['entryFee'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Method: Translates UI properties into exact keys required by your Pydantic model
  Map<String, dynamic> toJson() {
    // Combine date and time back into the single ISO format Pydantic requires
    String combinedDateTime = (date.isNotEmpty && time.isNotEmpty)
        ? '${date}T$time'
        : DateTime.now().toIso8601String();

    return {
      'id': id,
      'nameOfTheEvent': eventName, // Matches backend nameOfTheEvent constraint
      'dateAndTime': combinedDateTime, // Matches backend dateAndTime constraint
      'entryFee': entryFee, // Matches backend entryFee constraint
    };
  }
}
