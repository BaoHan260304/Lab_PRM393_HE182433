/// KHUÔN ĐÚC SẢN PHẨM (Product Model - Lab 9)
class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
  });

  // PHỄU ĐÚC TỪ MAP JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'General',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  // CHUYỂN THÀNH MAP ĐỂ GHI VÀO FILE JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
    };
  }

  // HÀM SAO CHÉP BIẾN THỂ (Hỗ trợ chức năng Edit ở Lab 9.3)
  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? category,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
    );
  }
}
