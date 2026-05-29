class Weapon {
  final String id;
  final String name;
  final String type;
  final String description;
  final int stock;
  final String image;
  final double price;
  final String banner;
  final String showcase1;
  final String showcase2;
  final String showcase3;
  final String ratings;
  final String dmg;
  final String critRate;
  final String critDmg;

  Weapon({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.image,
    required this.price,
    required this.banner,
    required this.showcase1,
    required this.showcase2,
    required this.showcase3,
    required this.ratings,
    required this.dmg,
    required this.critRate,
    required this.critDmg,
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
      banner: (json['banner'] ?? 'assets/Product/mistsplitter Banner.png') as String,
      showcase1: (json['showcase1'] ?? 'assets/Product/Missplitter showcase.png') as String,
      showcase2: (json['showcase2'] ?? 'assets/Product/mistsplitter Banner.png') as String,
      showcase3: (json['showcase3'] ?? 'assets/Product/Missplitter showcase2.png') as String,
      ratings: (json['ratings'] ?? '5.0').toString(),
      dmg: (json['dmg'] ?? '0').toString(),
      critRate: (json['crit_rate'] ?? json['critRate'] ?? '0%').toString(),
      critDmg: (json['crit_dmg'] ?? json['critDmg'] ?? '0%').toString(),
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
      'banner': banner,
      'showcase1': showcase1,
      'showcase2': showcase2,
      'showcase3': showcase3,
      'ratings': ratings,
      'crit_rate': critRate,
      'crit_dmg': critDmg,
      'dmg': dmg,
    };
  }
}
