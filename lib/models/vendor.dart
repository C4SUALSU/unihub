class Vendor {
  final int id;
  final String name;
  final String contact;
  final String? category; // e.g., "Food", "Stationery"

  Vendor({
    required this.id,
    required this.name,
    required this.contact,
    this.category,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'category': category,
    };
  }
}