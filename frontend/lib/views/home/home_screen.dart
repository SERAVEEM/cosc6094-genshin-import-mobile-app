import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weapon_provider.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/category_chip.dart';
import 'widgets/weapon_hero_card.dart';
import 'widgets/trending_item_tile.dart';
import '../detail/detail_screen.dart';
import '../history/history_screen.dart';
import '../admin/admin_dashboard.dart';
import '../shared/loading_skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<WeaponProvider>(context, listen: false).fetchCatalog();
      Provider.of<TransactionProvider>(context, listen: false).fetchHistory();
    });
  }

  Widget _buildHomeView(BuildContext context, WeaponProvider weaponProvider, AuthProvider authProvider) {
    if (weaponProvider.isLoading && weaponProvider.rawWeapons.isEmpty) {
      return const Center(child: CatalogSkeleton());
    }
    
    if (weaponProvider.errorMessage.isNotEmpty && weaponProvider.rawWeapons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weaponProvider.errorMessage, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => weaponProvider.fetchCatalog(),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    final activeWeapons = weaponProvider.weapons;
    final heroWeapon = activeWeapons.isNotEmpty ? activeWeapons.first : null;
    final trendingWeapons = activeWeapons.isNotEmpty ? activeWeapons.skip(1).toList() : [];

    return RefreshIndicator(
      onRefresh: () => weaponProvider.fetchCatalog(),
      color: AppTheme.accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(
                    label: 'All',
                    isSelected: weaponProvider.selectedCategory == 'All',
                    icon: Icons.grid_view_rounded,
                    onTap: () => weaponProvider.selectCategory('All'),
                  ),
                  CategoryChip(
                    label: 'Claymore',
                    isSelected: weaponProvider.selectedCategory == 'Claymore',
                    icon: Icons.gavel_rounded,
                    onTap: () => weaponProvider.selectCategory('Claymore'),
                  ),
                  CategoryChip(
                    label: 'Sword',
                    isSelected: weaponProvider.selectedCategory == 'Sword',
                    icon: Icons.colorize_outlined,
                    onTap: () => weaponProvider.selectCategory('Sword'),
                  ),
                  CategoryChip(
                    label: 'Catalyst',
                    isSelected: weaponProvider.selectedCategory == 'Catalyst',
                    icon: Icons.auto_stories_rounded,
                    onTap: () => weaponProvider.selectCategory('Catalyst'),
                  ),
                  CategoryChip(
                    label: 'Bow',
                    isSelected: weaponProvider.selectedCategory == 'Bow',
                    icon: Icons.architecture_rounded,
                    onTap: () => weaponProvider.selectCategory('Bow'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space6),
            
            if (heroWeapon != null) ...[
              WeaponHeroCard(
                weapon: heroWeapon,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WeaponDetailScreen(weaponId: heroWeapon.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.space6),
            ],

            Text(
              "Trending Items",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppTheme.space4),

            if (trendingWeapons.isEmpty && heroWeapon == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text('Katalog kosong!', style: TextStyle(color: AppTheme.textMuted)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trendingWeapons.length,
                itemBuilder: (context, index) {
                  final weapon = trendingWeapons[index];
                  return TrendingItemTile(
                    weapon: weapon,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WeaponDetailScreen(weaponId: weapon.id),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final weaponProvider = Provider.of<WeaponProvider>(context);

    final List<Widget> views = [
      _buildHomeView(context, weaponProvider, authProvider),
      authProvider.isAdmin ? const AdminDashboard() : _buildSearchView(context, weaponProvider),
      _buildWishlistView(),
      const HistoryScreen(),
    ];

    return Scaffold(
      appBar: _currentIndex == 0 ? AppBar(
        title: const Text('Weapons'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              color: AppTheme.cardBg,
              onSelected: (val) {
                if (val == 'logout') {
                  authProvider.logout();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    'Logged as: ${authProvider.user?.name}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accent,
                backgroundImage: NetworkImage('https://emoji.gg/assets/emoji/8816-pepe-frog.png'),
              ),
            ),
          ),
        ],
      ) : null,
      body: views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: AppTheme.accent,
        unselectedItemColor: AppTheme.textMuted,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(authProvider.isAdmin ? Icons.admin_panel_settings_outlined : Icons.search_outlined),
            activeIcon: Icon(authProvider.isAdmin ? Icons.admin_panel_settings : Icons.search),
            label: authProvider.isAdmin ? 'Admin' : 'Search',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView(BuildContext context, WeaponProvider weaponProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => weaponProvider.updateSearchQuery(val),
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search weapons...',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppTheme.borderSubtle),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: weaponProvider.weapons.isEmpty
                ? const Center(child: Text('No weapons found.', style: TextStyle(color: AppTheme.textMuted)))
                : ListView.builder(
                    itemCount: weaponProvider.weapons.length,
                    itemBuilder: (ctx, idx) {
                      final weapon = weaponProvider.weapons[idx];
                      return TrendingItemTile(
                        weapon: weapon,
                        onTap: () {
                          Navigator.of(ctx).push(
                            MaterialPageRoute(
                              builder: (_) => WeaponDetailScreen(weaponId: weapon.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_rounded, size: 64, color: AppTheme.accent),
          SizedBox(height: 16),
          Text(
            'My Wishlist',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Wishlist matches are currently in progress.',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
