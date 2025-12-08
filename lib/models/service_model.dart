class Service {
  final String id;
  final String name;
  final String type; // 'mechanic' or 'towing'
  final double price;
  final String currency;
  final String? description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.currency,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'price': price,
      'currency': currency,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}