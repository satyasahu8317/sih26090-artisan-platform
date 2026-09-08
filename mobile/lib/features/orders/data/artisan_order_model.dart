class ArtisanOrder {
  final String id;
  final String buyerId;
  final String artisanId;
  final String? productId;
  final int requestedQty;
  final int? acceptedQty;
  final double? unitPrice;
  final double? totalAmount;
  final DateTime? requiredBy;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderBuyer buyer;
  final OrderProduct? product;

  const ArtisanOrder({
    required this.id,
    required this.buyerId,
    required this.artisanId,
    required this.productId,
    required this.requestedQty,
    required this.acceptedQty,
    required this.unitPrice,
    required this.totalAmount,
    required this.requiredBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.buyer,
    required this.product,
  });

  factory ArtisanOrder.fromJson(Map<String, dynamic> json) {
    return ArtisanOrder(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      artisanId: json['artisanId'] as String,
      productId: json['productId'] as String?,
      requestedQty: (json['requestedQty'] as num).toInt(),
      acceptedQty: (json['acceptedQty'] as num?)?.toInt(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      requiredBy: json['requiredBy'] == null
          ? null
          : DateTime.parse(json['requiredBy'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      buyer: OrderBuyer.fromJson(json['buyer'] as Map<String, dynamic>),
      product: json['product'] == null
          ? null
          : OrderProduct.fromJson(
              json['product'] as Map<String, dynamic>,
            ),
    );
  }
}

class OrderBuyer {
  final String name;
  final String businessName;
  final String businessType;

  const OrderBuyer({
    required this.name,
    required this.businessName,
    required this.businessType,
  });

  factory OrderBuyer.fromJson(Map<String, dynamic> json) {
    return OrderBuyer(
      name: json['name'] as String,
      businessName: json['businessName'] as String,
      businessType: json['businessType'] as String,
    );
  }
}

class OrderProduct {
  final String id;
  final Map<String, dynamic> productName;
  final String? imageUrl;

  const OrderProduct({
    required this.id,
    required this.productName,
    required this.imageUrl,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] as String,
      productName: Map<String, dynamic>.from(json['productName'] as Map),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  String get displayName =>
      (productName['en'] ?? productName['hi'])?.toString() ?? '';
}

class ArtisanOrderDetail {
  final String id;
  final String buyerId;
  final String artisanId;
  final String? productId;
  final int requestedQty;
  final int? acceptedQty;
  final double? unitPrice;
  final double? totalAmount;
  final DateTime? requiredBy;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderBuyerDetail buyer;
  final OrderArtisanDetail artisan;
  final OrderProduct? product;

  const ArtisanOrderDetail({
    required this.id,
    required this.buyerId,
    required this.artisanId,
    required this.productId,
    required this.requestedQty,
    required this.acceptedQty,
    required this.unitPrice,
    required this.totalAmount,
    required this.requiredBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.buyer,
    required this.artisan,
    required this.product,
  });

  factory ArtisanOrderDetail.fromJson(Map<String, dynamic> json) {
    return ArtisanOrderDetail(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      artisanId: json['artisanId'] as String,
      productId: json['productId'] as String?,
      requestedQty: (json['requestedQty'] as num).toInt(),
      acceptedQty: (json['acceptedQty'] as num?)?.toInt(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      requiredBy: json['requiredBy'] == null
          ? null
          : DateTime.parse(json['requiredBy'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      buyer: OrderBuyerDetail.fromJson(json['buyer'] as Map<String, dynamic>),
      artisan: OrderArtisanDetail.fromJson(
        json['artisan'] as Map<String, dynamic>,
      ),
      product: json['product'] == null
          ? null
          : OrderProduct.fromJson(json['product'] as Map<String, dynamic>),
    );
  }
}

class OrderBuyerDetail {
  final String id;
  final String name;
  final String businessName;

  const OrderBuyerDetail({
    required this.id,
    required this.name,
    required this.businessName,
  });

  factory OrderBuyerDetail.fromJson(Map<String, dynamic> json) {
    return OrderBuyerDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      businessName: json['businessName'] as String,
    );
  }
}

class OrderArtisanDetail {
  final String id;
  final String name;

  const OrderArtisanDetail({
    required this.id,
    required this.name,
  });

  factory OrderArtisanDetail.fromJson(Map<String, dynamic> json) {
    return OrderArtisanDetail(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}