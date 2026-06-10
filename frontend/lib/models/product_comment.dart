class ProductComment {
  final String id;
  final String weaponId;
  final String userId;
  final String userName;
  final int rating;
  final String content;
  final DateTime createdAt;

  ProductComment({
    required this.id,
    required this.weaponId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory ProductComment.fromJson(Map<String, dynamic> json) {
    return ProductComment(
      id: json['id'] as String,
      weaponId: json['weapon_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      rating: int.parse(json['rating'].toString()),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'].toString()).toLocal(),
    );
  }
}
