class Event {
  final int id;
  final String title;
  final DateTime date;
  final String contactInfo;
  final String whatsappNumber;
  final List<String> links;
  final String? imageUrl;
  final String userId;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.contactInfo,
    required this.whatsappNumber,
    required this.links,
    this.imageUrl,
    required this.userId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      contactInfo: json['contact_info'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      links: (json['links'] as List<dynamic>?)
              ?.map((link) => link.toString())
              .toList() ??
          [],
      imageUrl: json['image_url'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'contact_info': contactInfo,
      'whatsapp_number': whatsappNumber,
      'links': links,
      'image_url': imageUrl,
      'user_id': userId,
    };
  }
}