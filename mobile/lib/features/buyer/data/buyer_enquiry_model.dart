class BuyerEnquiry {
  final String id;
  final String? artisanId;
  final String? productId;
  final String? message;
  final String? status;

  BuyerEnquiry({
    required this.id,
    this.artisanId,
    this.productId,
    this.message,
    this.status,
  });

  factory BuyerEnquiry.fromJson(Map<String, dynamic> json) {
    return BuyerEnquiry(
      id: json['id'] as String,
      artisanId: json['artisanId'] as String?,
      productId: json['productId'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String?,
    );
  }
}class BuyerEnquiryMessage {
  final String id;
  final String? senderId;
  final String message;
  final DateTime? createdAt;
  final String? senderRole;

  BuyerEnquiryMessage({
    required this.id,
    this.senderId,
    required this.message,
    this.createdAt,
    this.senderRole,
  });

  factory BuyerEnquiryMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuyerEnquiryMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String?,
      message: json['message'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      senderRole: json['senderRole'] as String?,
    );
  }
}