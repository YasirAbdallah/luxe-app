class Product {
  final String id;
  final String name;
  final String description;
  final Map<String, double> sizePrices;
  final List<String> imageUrls; // List of image URLs

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.sizePrices,
    required this.imageUrls, // Update here
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sizePrices': sizePrices,
      'imageUrls': imageUrls, // Update here
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      sizePrices: Map<String, double>.from(map['sizePrices'] ?? {}),
      imageUrls: List<String>.from(map['imageUrls'] ?? []), // Update here
    );
  }
}
