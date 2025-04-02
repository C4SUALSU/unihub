class Event {
  final int id;
  final String title;
  final DateTime date;
  final String location;
  final String? description;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    this.description,
  });

  // Convert JSON from Supabase to an Event object
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']), // Ensure Supabase stores dates as ISO strings
      location: json['location'],
      description: json['description'],
    );
  }

  // Convert Event object to JSON for sending to Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
    };
  }
}