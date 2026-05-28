import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weapon.dart';

class WeaponService {
  static final List<Map<String, dynamic>> _defaultWeapons = [
    {
      'id': 'w1000001',
      'name': 'Mistsplitter Reforged',
      'type': 'Sword',
      'description': 'The Ultimate last slash. A sword that crackles with a fierce violet light.',
      'stock': 5,
      'image': 'assets/Home/download 1.png',
      'price': 500.0,
    },
    {
      'id': 'w1000002',
      'name': 'Sword of Destiny',
      'type': 'Sword',
      'description': 'The last tears of Gyang-yu.',
      'stock': 3,
      'image': 'assets/Product/Sword of destiny.png',
      'price': 700.0,
    },
    {
      'id': 'w1000003',
      'name': 'Susano\'o Sword',
      'type': 'Sword',
      'description': 'Raiden\'s purple susano\'o.',
      'stock': 8,
      'image': 'assets/Product/Susano\'o sword.png',
      'price': 600.0,
    },
    {
      'id': 'w1000004',
      'name': 'Wolf\'s Gravestone',
      'type': 'Claymore',
      'description': 'A longsword used by the Wolf Knight. Originally just a heavy sheet of iron, it gained legendary power.',
      'stock': 5,
      'image': 'https://static.wikia.nocookie.net/gensin-impact/images/4/4f/Weapon_Wolf%27s_Gravestone.png/revision/latest?cb=20201026131436',
      'price': 1500.0,
    },
    {
      'id': 'w1000005',
      'name': 'Kagura\'s Verity',
      'type': 'Catalyst',
      'description': 'The bells used when performing the Kagura Dance.',
      'stock': 4,
      'image': 'https://static.wikia.nocookie.net/gensin-impact/images/9/96/Weapon_Kagura%27s_Verity.png/revision/latest?cb=20220216170857',
      'price': 1200.0,
    },
    {
      'id': 'w1000006',
      'name': 'Aqua Simulacra',
      'type': 'Bow',
      'description': 'A longbow that glistens with an unpredictable water color.',
      'stock': 6,
      'image': 'https://static.wikia.nocookie.net/gensin-impact/images/9/9e/Weapon_Aqua_Simulacra.png/revision/latest?cb=20220601053155',
      'price': 1100.0,
    }
  ];

  static Future<List<Weapon>> getCatalog() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final prefs = await SharedPreferences.getInstance();
    
    final weaponsStr = prefs.getString('mock_weapons_v4');
    if (weaponsStr == null) {
      await prefs.setString('mock_weapons_v4', jsonEncode(_defaultWeapons));
      return _defaultWeapons.map((item) => Weapon.fromJson(item)).toList();
    }
    
    final List<dynamic> list = jsonDecode(weaponsStr);
    return list.map((item) => Weapon.fromJson(item)).toList();
  }

  static Future<Weapon> getWeaponById(String id) async {
    final catalog = await getCatalog();
    return catalog.firstWhere(
      (w) => w.id == id,
      orElse: () => throw Exception('Produk tidak ditemukan!'),
    );
  }

  static Future<Weapon> createWeapon(Map<String, dynamic> weaponData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final catalog = await getCatalog();

    final newId = 'w_${DateTime.now().millisecondsSinceEpoch}';
    final newWeaponMap = {
      'id': newId,
      'name': weaponData['name'] ?? 'Unnamed Weapon',
      'type': weaponData['type'] ?? 'Sword',
      'description': weaponData['description'] ?? '',
      'stock': weaponData['stock'] is int ? weaponData['stock'] : int.parse(weaponData['stock']?.toString() ?? '0'),
      'image': weaponData['image'] ?? 'assets/Home/download 1.png',
      'price': weaponData['price'] is double ? weaponData['price'] : double.parse(weaponData['price']?.toString() ?? '0.0'),
    };

    final updatedCatalog = catalog.map((w) => w.toJson()).toList()..add(newWeaponMap);
    await prefs.setString('mock_weapons_v4', jsonEncode(updatedCatalog));

    return Weapon.fromJson(newWeaponMap);
  }

  static Future<Weapon> updateWeapon(String id, Map<String, dynamic> weaponData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final catalog = await getCatalog();

    final index = catalog.indexWhere((w) => w.id == id);
    if (index == -1) {
      throw Exception('Produk tidak ditemukan!');
    }

    final updatedWeaponMap = {
      'id': id,
      'name': weaponData['name'] ?? catalog[index].name,
      'type': weaponData['type'] ?? catalog[index].type,
      'description': weaponData['description'] ?? catalog[index].description,
      'stock': weaponData['stock'] is int ? weaponData['stock'] : int.parse(weaponData['stock']?.toString() ?? catalog[index].stock.toString()),
      'image': weaponData['image'] ?? catalog[index].image,
      'price': weaponData['price'] is double ? weaponData['price'] : double.parse(weaponData['price']?.toString() ?? catalog[index].price.toString()),
    };

    final updatedList = catalog.map((w) => w.toJson()).toList();
    updatedList[index] = updatedWeaponMap;
    await prefs.setString('mock_weapons_v4', jsonEncode(updatedList));

    return Weapon.fromJson(updatedWeaponMap);
  }

  static Future<void> deleteWeapon(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final prefs = await SharedPreferences.getInstance();
    final catalog = await getCatalog();

    final updatedList = catalog.where((w) => w.id != id).map((w) => w.toJson()).toList();
    await prefs.setString('mock_weapons_v4', jsonEncode(updatedList));
  }
}
