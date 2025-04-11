class Vendor {
  final int id;
  final String name;
  final String contact; // Existing field
  final String? category;
  final String? profileImageUrl;
  final String? email; // Add this line
  final String? imagePath;

  Vendor({
    required this.id,
    required this.name,
    required this.contact,
    this.category,
    this.profileImageUrl,
    this.email, // Add to constructor
    this.imagePath,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      category: json['category'],
      profileImageUrl: json['profile_image_url'] as String?,
      email: json['email'], // Add this line (match your Supabase column name)
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'category': category,
      'profile_image_url': profileImageUrl,
      'email': email, // Add this line
      'image_path': imagePath,
    };
  }
}