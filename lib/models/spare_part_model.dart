class SparePart {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final String supplier;
  final String description;
  final String image;
  final String status;

  SparePart({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.supplier,
    required this.description,
    required this.image,
    required this.status,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      supplier: json['supplier'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
    );
  }
}