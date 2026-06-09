class Transaction {
  final String id;
  final String userId;
  final String weaponId;
  final int quantity;
  final double totalPrice;
  final String createdAt;
  final String? weaponName;
  final String? weaponType;
  final String? weaponImage;
  final String? redeemCode;

  Transaction({
    required this.id,
    required this.userId,
    required this.weaponId,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
    this.weaponName,
    this.weaponType,
    this.weaponImage,
    this.redeemCode,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weaponId: json['weapon_id'] as String,
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
      totalPrice: json['total_price'] is double ? json['total_price'] : double.parse(json['total_price'].toString()),
      createdAt: json['created_at'] != null ? json['created_at'] as String : DateTime.now().toIso8601String(),
      weaponName: json['weapon_name'] as String?,
      weaponType: json['weapon_type'] as String?,
      weaponImage: json['weapon_image'] as String?,
      redeemCode: json['redeem_code'] as String?,
    );
  }
}
