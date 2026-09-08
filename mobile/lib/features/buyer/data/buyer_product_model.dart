class BuyerProduct {
  final String id;
  final Map<String, dynamic> productName;
  final Map<String, dynamic>? description;
  final String? category;
  final String? material;
  final String? status;
  final List<dynamic>? tags;
  final String? imageUrl;
  final BuyerArtisan? artisan;

  BuyerProduct({
    required this.id,
    required this.productName,
    this.description,
    this.category,
    this.material,
    this.status,
    this.tags,
    this.imageUrl,
    this.artisan,
  });

  factory BuyerProduct.fromJson(Map<String, dynamic> json) {
    return BuyerProduct(
      id: json['id'] as String,
      productName: Map<String, dynamic>.from(
        json['productName'] ?? {},
      ),
      description: json['description'] != null
          ? Map<String, dynamic>.from(json['description'])
          : null,
      category: json['category'] as String?,
      material: json['material'] as String?,
      status: json['status'] as String?,
      tags: json['tags'] as List<dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      artisan: json['artisan'] != null
          ? BuyerArtisan.fromJson(
              Map<String, dynamic>.from(json['artisan']),
            )
          : null,
    );
  }
}

class BuyerArtisan {
  final String id;
  final String? name;
  final String? craftType;
  final String? state;
  final String? district;
  final String? preferredLanguage;

  BuyerArtisan({
    required this.id,
    this.name,
    this.craftType,
    this.state,
    this.district,
    this.preferredLanguage,
  });

  factory BuyerArtisan.fromJson(Map<String, dynamic> json) {
    return BuyerArtisan(
      id: json['id'] as String,
      name: json['name'] as String?,
      craftType: json['craftType'] as String?,
      state: json['state'] as String?,
      district: json['district'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
    );
  }
}