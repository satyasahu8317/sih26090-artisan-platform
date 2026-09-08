class BuyerOrder {
  final String id;
  final String? artisanId;
  final String? productId;
  final int? requestedQty;
  final double? unitPrice;
  final String? status;

  BuyerOrder({
    required this.id,
    this.artisanId,
    this.productId,
    this.requestedQty,
    this.unitPrice,
    this.status,
  });

  factory BuyerOrder.fromJson(Map<String, dynamic> json) {
    return BuyerOrder(
      id: json['id'] as String,
      artisanId: json['artisanId'] as String?,
      productId: json['productId'] as String?,
      requestedQty: json['requestedQty'] as int?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      status: json['status'] as String?,
    );
  }
}