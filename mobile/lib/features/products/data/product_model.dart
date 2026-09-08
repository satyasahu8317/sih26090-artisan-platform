class Product {
  final String id;
  final Map<String, dynamic> productName;
  final String category;
  final String? material;
  final Map<String, dynamic> description;
  final List<String> tags;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.productName,
    required this.category,
    required this.material,
    required this.description,
    required this.tags,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      productName: Map<String, dynamic>.from(json['productName'] as Map),
      category: json['category'] as String,
      material: json['material'] as String?,
      description: Map<String, dynamic>.from(json['description'] as Map),
      tags: List<String>.from(json['tags'] as List),
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get displayName =>
      (productName['en'] ?? productName['hi'])?.toString() ?? '';

  String get displayStatus =>
      status == 'PUBLISHED' ? 'Published' : 'Draft';
}

class CatalogueDraft {
  final Map<String, dynamic> productName;
  final Map<String, dynamic> description;
  final String category;
  final String? material;
  final List<String> tags;

  const CatalogueDraft({
    required this.productName,
    required this.description,
    required this.category,
    required this.material,
    required this.tags,
  });

  factory CatalogueDraft.fromJson(Map<String, dynamic> json) {
    return CatalogueDraft(
      productName: Map<String, dynamic>.from(json['productName'] as Map),
      description: Map<String, dynamic>.from(json['description'] as Map),
      category: json['category'] as String,
      material: json['material'] as String?,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  String get englishProductName => productName['en'] as String;
  String get englishDescription => description['en'] as String;
}