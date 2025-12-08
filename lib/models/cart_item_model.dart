class CartItem {
  final String id;
  final String productId;
  final String name;
  final String description;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      price: json['price'].toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? description,
    String? image,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}