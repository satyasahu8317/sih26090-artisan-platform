class ArtisanEnquiry {
  final String id;
  final String buyerId;
  final String artisanId;
  final String? productId;
  final String message;
  final String status;
  final DateTime createdAt;
  final EnquiryBuyer buyer;
  final EnquiryProduct? product;

  const ArtisanEnquiry({
    required this.id,
    required this.buyerId,
    required this.artisanId,
    required this.productId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.buyer,
    required this.product,
  });

  factory ArtisanEnquiry.fromJson(Map<String, dynamic> json) {
    return ArtisanEnquiry(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      artisanId: json['artisanId'] as String,
      productId: json['productId'] as String?,
      message: json['message'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      buyer: EnquiryBuyer.fromJson(json['buyer'] as Map<String, dynamic>),
      product: json['product'] == null
          ? null
          : EnquiryProduct.fromJson(
              json['product'] as Map<String, dynamic>,
            ),
    );
  }
}

class EnquiryBuyer {
  final String name;
  final String businessName;

  const EnquiryBuyer({
    required this.name,
    required this.businessName,
  });

  factory EnquiryBuyer.fromJson(Map<String, dynamic> json) {
    return EnquiryBuyer(
      name: json['name'] as String,
      businessName: json['businessName'] as String,
    );
  }
}

class EnquiryProduct {
  final String id;
  final Map<String, dynamic> productName;
  final String? imageUrl;

  const EnquiryProduct({
    required this.id,
    required this.productName,
    required this.imageUrl,
  });

  factory EnquiryProduct.fromJson(Map<String, dynamic> json) {
    return EnquiryProduct(
      id: json['id'] as String,
      productName: Map<String, dynamic>.from(json['productName'] as Map),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  String get displayName =>
      (productName['en'] ?? productName['hi'])?.toString() ?? '';
}

class EnquiryDetails {
  final String id;
  final String message;
  final String status;
  final DateTime createdAt;
  final EnquiryBuyer buyer;
  final EnquiryArtisan artisan;
  final EnquiryProduct? product;

  const EnquiryDetails({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.buyer,
    required this.artisan,
    required this.product,
  });

  factory EnquiryDetails.fromJson(Map<String, dynamic> json) {
    return EnquiryDetails(
      id: json['id'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      buyer: EnquiryBuyer.fromJson(json['buyer'] as Map<String, dynamic>),
      artisan: EnquiryArtisan.fromJson(
        json['artisan'] as Map<String, dynamic>,
      ),
      product: json['product'] == null
          ? null
          : EnquiryProduct.fromJson(
              json['product'] as Map<String, dynamic>,
            ),
    );
  }
}

class EnquiryArtisan {
  final String id;
  final String name;
  final String craftType;

  const EnquiryArtisan({
    required this.id,
    required this.name,
    required this.craftType,
  });

  factory EnquiryArtisan.fromJson(Map<String, dynamic> json) {
    return EnquiryArtisan(
      id: json['id'] as String,
      name: json['name'] as String,
      craftType: json['craftType'] as String,
    );
  }
}

class EnquiryMessage {
  final String id;
  final String enquiryId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final String senderRole;

  const EnquiryMessage({
    required this.id,
    required this.enquiryId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    required this.senderRole,
  });

  factory EnquiryMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>;
    return EnquiryMessage(
      id: json['id'] as String,
      enquiryId: json['enquiryId'] as String,
      senderId: json['senderId'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderRole: sender['role'] as String,
    );
  }
}