class Dish {
  final int id;
  final String title;
  final String? description; // Make nullable
  final String category;
  final List<String> imageUrls;
  final String? contactNumber; // Make nullable

  Dish({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.imageUrls,
    this.contactNumber,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'uncategorized', // Default value
      imageUrls: List<String>.from(json['imageUrls'] as List),
      contactNumber: json['contactNumber'] as String?,
    );
  }
}