class PosterDetails {
  final String? id;
  final String eventName;
  final String details;
  final String date; // Format: YYYY-MM-DD
  final String time; // Format: HH:MM:SS
  final String location;

  PosterDetails({
    this.id,
    required this.eventName,
    required this.details,
    required this.date,
    required this.time,
    required this.location,
  });

  factory PosterDetails.fromJson(Map<String, dynamic> json) {
    return PosterDetails(
      id: json['id'], // Assuming backend returns 'id'
      eventName: json['event_name'] ?? json['eventName'] ?? '',
      details: json['details'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'event_name': eventName,
      'details': details,
      'date': date,
      'time': time,
      'location': location,
    };
  }
}