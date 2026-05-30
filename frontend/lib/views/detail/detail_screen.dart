import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/weapon.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weapon_provider.dart';
import '../../providers/transaction_provider.dart';
import '../shared/error_dialog.dart';
import '../auth/login_screen.dart';
import '../shared/get_button.dart';
import '../../providers/wishlist_provider.dart';

class WeaponDetailScreen extends StatefulWidget {
  final String weaponId;

  const WeaponDetailScreen({
    super.key,
    required this.weaponId,
  });

  @override
  State<WeaponDetailScreen> createState() => _WeaponDetailScreenState();
}

class _WeaponDetailScreenState extends State<WeaponDetailScreen> {
  int _quantity = 1;
  bool _isPurchasing = false;



  Future<void> _buy(Weapon weapon) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to purchase items.')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final weaponProvider = Provider.of<WeaponProvider>(context, listen: false);

    try {
      await txProvider.purchaseItem(
        weapon.id,
        _quantity,
        onSuccess: (tx) {
          weaponProvider.fetchCatalog();
          if (mounted) {
            _showRedemptionDialog(context, weapon, tx);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  void _showRedemptionDialog(BuildContext context, Weapon weapon, Transaction tx) {
    final redeemCode = tx.redeemCode ?? 'NO-CODE';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff111622),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff3CDD3C).withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xff3CDD3C),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Order Successful!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for your purchase. Here is your unique item code to redeem in-game!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Item Preview Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff1c2436),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: (weapon.image.startsWith('http')
                                ? NetworkImage(weapon.image)
                                : AssetImage(weapon.image.startsWith('assets/') ? weapon.image : 'assets/images/${weapon.image}')) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weapon.name,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: ${tx.quantity}',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Redeem Code Container
                Text(
                  'REDEEM CODE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          redeemCode,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.accent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: redeemCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Redeem code copied!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy_rounded,
                          color: AppTheme.accent,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dismiss Dialog
                      Navigator.of(context).pop(); // Exit Detail Screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'RETURN TO SHOP',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCategoryIcon(String type) {
    switch (type) {
      case 'Sword':
        return 'asset/Icon/swords icon.png';
      case 'Claymore':
        return 'asset/Icon/Claymore icon.png';
      case 'Catalyst':
        return 'asset/Icon/catalyst icon.png';
      case 'Bow':
        return 'asset/Icon/Bow icon.png';
      default:
        return 'asset/Icon/swords icon.png';
    }
  }

  void _showPurchaseBottomSheet(BuildContext context, Weapon weapon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double totalPrice = weapon.price * _quantity;
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: BoxDecoration(
                color: const Color(0xff111622),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Purchase Weapon',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xff1c2436),
                          image: DecorationImage(
                            image: (weapon.id == 'w1000001'
                                ? const AssetImage('assets/Product/Missplitter reforged.png')
                                : (weapon.image.startsWith('http')
                                    ? NetworkImage(weapon.image)
                                    : AssetImage(weapon.image.startsWith('assets/') ? weapon.image : 'assets/images/${weapon.image}'))) as ImageProvider,
                            fit: BoxFit.cover,
                            onError: (err, stack) {},
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weapon.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              weapon.id == 'w1000001' ? 'The Ultimate last slash' : weapon.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.accent),
                            onPressed: _quantity > 1 ? () {
                              setSheetState(() {
                                _quantity--;
                              });
                            } : null,
                          ),
                          Text(
                            '$_quantity',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.accent),
                            onPressed: _quantity < weapon.stock ? () {
                              setSheetState(() {
                                _quantity++;
                              });
                            } : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Cost',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'asset/Icon/Primo icons.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            totalPrice.toStringAsFixed(0),
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _isPurchasing
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                      : ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _buy(weapon);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'CONFIRM PURCHASE',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsRow(Weapon weapon) {
    double ratingVal = 5.0;
    try {
      ratingVal = double.parse(weapon.ratings);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Colors.white.withValues(alpha: 0),
              width: 0,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(child: _buildStatItem('Ratings', weapon.ratings, extraWidget: _buildStars(ratingVal))),
            _buildDivider(),
            Expanded(child: _buildStatItem('DMG', weapon.dmg, subtitle: 'Melee')),
            _buildDivider(),
            Expanded(child: _buildStatItem('Critical', weapon.critRate, subtitle: 'Rate')),
            _buildDivider(),
            Expanded(child: _buildStatItem('Critical', weapon.critDmg, subtitle: 'Damage')),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return VerticalDivider(
      color: Colors.white.withValues(alpha: 1.0),
      width: 1,
      thickness: 1,
      indent: 8,
      endIndent: 8,
    );
  }

  Widget _buildStatItem(String label, String value, {String? subtitle, Widget? extraWidget}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 1.0),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 1.0),
            ),
          ),
        ],
        if (extraWidget != null) ...[
          const SizedBox(height: 2),
          extraWidget,
        ],
      ],
    );
  }

  Widget _buildStars(double rating) {
    int fullStars = rating.floor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.5),
          child: Icon(
            index < fullStars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 10,
            color: const Color(0xFFFFB300),
          ),
        ),
      ),
    );
  }

  Widget _buildGallery(Weapon weapon) {
    final List<String> slides = [
      weapon.showcase1,
      weapon.showcase2,
      weapon.showcase3,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24), // <-- Increased gap before gallery
        SizedBox(
          height: 100, // <-- Reduced height to match Figma gallery size
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return Container(
                width: 200, // <-- Reduced width to maintain the clean landscape aspect ratio
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: (slides[index].startsWith('http')
                        ? NetworkImage(slides[index])
                        : AssetImage(slides[index].startsWith('assets/') ? slides[index] : 'assets/images/${slides[index]}')) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(Weapon weapon) {
    double ratingVal = 5.0;
    try {
      ratingVal = double.parse(weapon.ratings);
    } catch (_) {}
    int fullStars = ratingVal.floor();

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ratings & Reviews',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                weapon.ratings,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < fullStars ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 18,
                        color: index < fullStars ? const Color(0xFFFFB300) : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '750 Ratings',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Helpful Reviews',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            'UNiyyyyy',
            '5 mo ago',
            'This Weapon is so good, GOAT, hands down. Makes me one shot every enemies. If you considere to buy this weapon, dont hesitate because this weapon is PEAK',
          ),
          _buildReviewCard(
            'Axelotel',
            '1 mo ago',
            'This Weapon is so good, GOAT, hands down. Makes me one shot every enemies. If you considere to buy this weapon, dont hesitate because this weapon is PEAK',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String username, String timeAgo, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1c2436),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              Text(
                timeAgo,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.only(right: 2.0),
                child: Icon(
                  Icons.star_rounded,
                  size: 12,
                  color: AppTheme.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weaponProvider = Provider.of<WeaponProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    
    final weaponIndex = weaponProvider.rawWeapons.indexWhere((w) => w.id == widget.weaponId);
    if (weaponIndex == -1) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    final weapon = weaponProvider.rawWeapons[weaponIndex];
    final bool isOutOfStock = weapon.stock <= 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Floating banner header matching Figma card layout
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24), // Rounded corners on all 4 sides matching Figma card
                      child: Container(
                        height: 180, // Narrow card aspect ratio matching Figma
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          image: DecorationImage(
                            image: (weapon.banner.startsWith('http')
                                ? NetworkImage(weapon.banner)
                                : AssetImage(weapon.banner.startsWith('assets/') ? weapon.banner : 'assets/images/${weapon.banner}')) as ImageProvider,
                            fit: BoxFit.cover,
                            onError: (err, stack) {},
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.4),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => wishlistProvider.toggleWishlist(weapon.id),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.4),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            wishlistProvider.isWishlisted(weapon.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: wishlistProvider.isWishlisted(weapon.id)
                                ? const Color(0xffFF5252)
                                : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Product info section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Thumbnail Card
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppTheme.cardBg,
                        image: DecorationImage(
                          image: (widget.weaponId == 'w1000001'
                              ? const AssetImage('assets/Product/Missplitter reforged.png')
                              : (weapon.image.startsWith('http')
                                  ? NetworkImage(weapon.image)
                                  : AssetImage(weapon.image.startsWith('assets/') ? weapon.image : 'assets/images/${weapon.image}'))) as ImageProvider,
                          fit: BoxFit.cover,
                          onError: (err, stack) {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Product Title details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weapon.name == 'Mistsplitter Reforged' ? 'Missplitter Reforged' : weapon.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.weaponId == 'w1000001' ? 'The Ultimate last slash' : weapon.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isOutOfStock ? 'Out of Stock' : 'In Stock (${weapon.stock} items left)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isOutOfStock ? const Color(0xffFF5252) : const Color(0xff3CDD3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Chip, Get Button, and Price tag
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                _getCategoryIcon(weapon.type),
                                width: 10,
                                height: 10,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                weapon.type,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GetButton(
                          onTap: isOutOfStock ? null : () => _showPurchaseBottomSheet(context, weapon),
                          width: 64,
                          height: 28,
                          fontSize: 12,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'asset/Icon/Primo icons.png',
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                weapon.price.toStringAsFixed(0),
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xff8AD4FF),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Stats grid block
              _buildStatsRow(weapon),
              
              // Screenshot Gallery row
              _buildGallery(weapon),
              
              // Ratings & Reviews section
              _buildReviewsSection(weapon),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          Navigator.of(context).pop(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withValues(alpha: 0.4),
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
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
}
