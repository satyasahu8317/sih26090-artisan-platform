class BuyerProfile {
  final String? id;
  final String? name;
  final String? businessName;
  final String? businessType;
  final String? state;
  final String? district;

  BuyerProfile({
    this.id,
    this.name,
    this.businessName,
    this.businessType,
    this.state,
    this.district,
  });

  factory BuyerProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return BuyerProfile(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      businessName:
          json['businessName']?.toString(),
      businessType:
          json['businessType']?.toString(),
      state: json['state']?.toString(),
      district:
          json['district']?.toString(),
    );
  }
}