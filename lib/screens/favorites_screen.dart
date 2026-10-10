import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/settings_provider.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';
import 'food_detail_screen.dart';
import 'cart_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _selectedCategory = 'All';

  String _formatLkr(double val) {
    return 'LKR ${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoritesProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context);
    final allFavorites = favProvider.favoriteFoodItems;

    // Filter by category
    final displayedItems = _selectedCategory == 'All'
        ? allFavorites
        : allFavorites.where((item) => item.category == _selectedCategory).toList();

    // Extract unique categories for filter chips
    final availableCategories = ['All', ...{...allFavorites.map((e) => e.category)}];

    final double totalFavoritesSum = allFavorites.fold(0.0, (sum, item) => sum + item.priceLkr);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Text(settings.tr('tab_favorites'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${allFavorites.length}',
                style: const TextStyle(
                  color: AppTheme.accentRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (allFavorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.accentRed),
              tooltip: 'Clear All Favorites',
              onPressed: () => _showClearConfirmation(context, favProvider),
            ),
        ],
      ),
      body: allFavorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded, size: 64, color: AppTheme.accentRed),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Favorites Saved Yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the heart icon on any mouthwatering dish or signature feast to save it here for quick ordering.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Category Filter Chips
                if (availableCategories.length > 2)
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      scrollDirection: Axis.horizontal,
                      itemCount: availableCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = availableCategories[idx];
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        );
                      },
                    ),
                  ),

                // Grid of Favorite Dishes
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: displayedItems.length,
                    itemBuilder: (context, index) {
                      final item = displayedItems[index];
                      return _buildFavoriteCard(context, item, favProvider, cart);
                    },
                  ),
                ),
              ],
            ),
      bottomSheet: allFavorites.isNotEmpty
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    for (final item in allFavorites) {
                      cart.addToCart(foodItem: item);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added all ${allFavorites.length} favorite dishes to your cart! 🛒'),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        action: SnackBarAction(
                          label: 'View Cart',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                  label: Text(
                    '${settings.tr('add_all_cart')} (${_formatLkr(totalFavoritesSum)})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    FoodItem item,
    FavoritesProvider favProvider,
    CartProvider cart,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FoodDetailScreen(foodItem: item)),
        );
      },
      child: Container(
        decoration: AppTheme.glassDecoration(
          opacity: 0.92,
          borderRadius: 18,
          blurRadius: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Favorite Toggle
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    item.imageUrl,
                    height: 124,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 124,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
                if (item.isHalal)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('HALAL', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.92),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.favorite_rounded, color: AppTheme.accentRed, size: 18),
                      onPressed: () {
                        favProvider.toggleFavorite(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed ${item.name} from favorites'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.restaurantName,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppTheme.starYellow, size: 14),
                      const SizedBox(width: 3),
                      Text('${item.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      const Icon(Icons.access_time_rounded, color: AppTheme.textSecondary, size: 11),
                      const SizedBox(width: 2),
                      Text(item.deliveryTime, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _formatLkr(item.priceLkr),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Interactive Quick Add Button
                      InkWell(
                        onTap: () {
                          cart.addToCart(foodItem: item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${item.name} to cart! 🛒'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              action: SnackBarAction(
                                label: 'Cart',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                                },
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, FavoritesProvider favProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Favorites?'),
        content: const Text('Are you sure you want to remove all saved items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed, foregroundColor: Colors.white),
            onPressed: () {
              favProvider.clearAllFavorites();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
