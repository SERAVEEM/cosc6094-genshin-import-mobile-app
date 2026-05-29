import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genshin_import/models/weapon.dart';
import 'package:genshin_import/models/user.dart';
import 'package:genshin_import/models/transaction.dart';
import 'package:genshin_import/providers/auth_provider.dart';
import 'package:genshin_import/providers/weapon_provider.dart';
import 'package:genshin_import/providers/transaction_provider.dart';
import 'package:genshin_import/providers/wishlist_provider.dart';
import 'package:genshin_import/views/auth/login_screen.dart';
import 'package:genshin_import/views/auth/register_screen.dart';
import 'package:genshin_import/views/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Model Serialization Tests', () {
    test('Weapon model fromJson and toJson', () {
      final json = {
        'id': 'w101',
        'name': 'Wolf\'s Gravestone',
        'type': 'Claymore',
        'description': 'A legendary sword.',
        'stock': 5,
        'image': 'wolf.png',
        'price': 1500.0,
        'banner': 'banner.png',
        'showcase1': 's1.png',
        'showcase2': 's2.png',
        'showcase3': 's3.png',
        'ratings': '4.9',
        'dmg': '250',
        'crit_rate': '40%',
        'crit_dmg': '150%',
      };
      final weapon = Weapon.fromJson(json);
      expect(weapon.id, 'w101');
      expect(weapon.name, 'Wolf\'s Gravestone');
      expect(weapon.type, 'Claymore');
      expect(weapon.price, 1500.0);
      expect(weapon.banner, 'banner.png');
      expect(weapon.showcase1, 's1.png');
      expect(weapon.showcase2, 's2.png');
      expect(weapon.showcase3, 's3.png');
      expect(weapon.ratings, '4.9');
      expect(weapon.dmg, '250');
      expect(weapon.critRate, '40%');
      expect(weapon.critDmg, '150%');

      final outJson = weapon.toJson();
      expect(outJson['id'], 'w101');
      expect(outJson['price'], 1500.0);
      expect(outJson['banner'], 'banner.png');
      expect(outJson['crit_rate'], '40%');
      expect(outJson['crit_dmg'], '150%');
    });

    test('User model fromJson and toJson', () {
      final json = {
        'id': 'u101',
        'name': 'Tabibito',
        'email': 'tabibito@test.com',
        'role': 'user',
      };
      final user = User.fromJson(json);
      expect(user.id, 'u101');
      expect(user.role, 'user');

      final outJson = user.toJson();
      expect(outJson['email'], 'tabibito@test.com');
    });

    test('Transaction model fromJson', () {
      final json = {
        'id': 'tx101',
        'user_id': 'u101',
        'weapon_id': 'w101',
        'quantity': 2,
        'total_price': 3000.0,
        'created_at': '2026-05-29T12:00:00Z',
        'weapon_name': 'Wolf\'s Gravestone',
        'weapon_type': 'Claymore',
        'weapon_image': 'wolf.png',
      };
      final tx = Transaction.fromJson(json);
      expect(tx.id, 'tx101');
      expect(tx.quantity, 2);
      expect(tx.weaponName, 'Wolf\'s Gravestone');
    });
  });

  group('Provider Tests', () {
    test('WeaponProvider Category & Search states', () {
      final provider = WeaponProvider();
      expect(provider.selectedCategory, 'All');
      expect(provider.searchQuery, '');

      provider.selectCategory('Claymore');
      expect(provider.selectedCategory, 'Claymore');

      provider.updateSearchQuery('Homa');
      expect(provider.searchQuery, 'Homa');
    });

    test('WishlistProvider state toggles correctly', () {
      final provider = WishlistProvider();
      expect(provider.isWishlisted('w101'), false);

      provider.toggleWishlist('w101');
      expect(provider.isWishlisted('w101'), true);

      provider.toggleWishlist('w101');
      expect(provider.isWishlisted('w101'), false);
    });
  });

  group('Widget Smoke Tests', () {
    Widget createTestApp(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => WeaponProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('LoginScreen smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('LOG IN'), findsOneWidget);
    });

    testWidgets('RegisterScreen smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Register'), findsWidgets);
      expect(find.text('Name'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('REGISTER'), findsOneWidget);
    });

    testWidgets('HomeScreen smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const HomeScreen()));
      // Advance virtual time past the simulated API latency timers (600ms maximum)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });
  });
}
