class Weapon {
  final String id;
  final String name;
  final String type;
  final String description;
  final int stock;
  final String image;
  final double price;

  Weapon({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.image,
    required this.price,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      stock: json['stock'] is int ? json['stock'] : int.parse(json['stock'].toString()),
      image: json['image'] as String,
      price: json['price'] is double ? json['price'] : double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'stock': stock,
      'image': image,
      'price': price,
    };
  }
}
