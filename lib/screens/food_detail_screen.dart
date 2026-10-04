import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late SpiceOption _selectedSpice;
  int _quantity = 1;
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSpice = widget.foodItem.spiceLevels.length > 1
        ? widget.foodItem.spiceLevels[1] // Medium Spicy default
        : (widget.foodItem.spiceLevels.isNotEmpty ? widget.foodItem.spiceLevels.first : SpiceOption(id: 's0', name: 'Standard', iconEmoji: '🌶️'));
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get _calculatedUnitPriceLkr => widget.foodItem.priceLkr + _selectedSpice.extraPriceLkr;

  double get _totalPriceLkr => _calculatedUnitPriceLkr * _quantity;

  String _formatPrice(double val) {
    return 'LKR ${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFav = favoritesProvider.isFavorite(widget.foodItem.id);

    return Scaffold(
      backgroundColor: Colors.black45, // Glass overlay backdrop
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Food Image Header
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppTheme.lightBackground,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, color: AppTheme.primaryGreen, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Bonchi Choice',
                        style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppTheme.accentRed : Colors.white,
                        size: 20,
                      ),
                      onPressed: () => favoritesProvider.toggleFavorite(widget.foodItem),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.foodItem.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black26, Colors.transparent, Colors.black87],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),

                      // Floating Badges on image
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('Bestseller', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.star, color: AppTheme.starYellow, size: 14),
                                  SizedBox(width: 4),
                                  Text('Pilawaos Special', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Detail Content Sheet
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.foodItem.name,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                                  ),
                                  if (widget.foodItem.sinhalaName.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.foodItem.sinhalaName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              _formatPrice(widget.foodItem.priceLkr),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Subtitle info pills
                        Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppTheme.starYellow, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.foodItem.rating} (${widget.foodItem.reviewCountText})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Text('•  ${widget.foodItem.servesText}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Halal Certified', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.foodItem.description,
                          style: TextStyle(fontSize: 12.5, color: theme.textTheme.bodyMedium?.color, height: 1.5),
                        ),

                        const SizedBox(height: 24),

                        // Customize Spice Level Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('Customize Spice Level', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                  ),
                                  child: const Text('REQUIRED', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Text('Select 1', style: TextStyle(fontSize: 11.5, color: theme.textTheme.bodyMedium?.color)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text('ඔබගේ සැර ප්‍රමාණය තෝරන්න', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),

                        const SizedBox(height: 14),

                        // Spice Options Selector Horizontal Row
                        Row(
                          children: widget.foodItem.spiceLevels.map((spice) {
                            final isSelected = _selectedSpice.id == spice.id;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedSpice = spice),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primaryGreen : AppTheme.lightBorder,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(spice.iconEmoji, style: const TextStyle(fontSize: 22)),
                                          const SizedBox(height: 6),
                                          Text(
                                            spice.name,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                                            ),
                                          ),
                                          if (spice.extraPriceLkr > 0) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              '+LKR ${spice.extraPriceLkr.toInt()}',
                                              style: const TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (isSelected)
                                        const Positioned(
                                          top: -8,
                                          right: -2,
                                          child: CircleAvatar(
                                            radius: 9,
                                            backgroundColor: AppTheme.primaryGreen,
                                            child: Icon(Icons.check, color: Colors.white, size: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom Floating Sticky Cart Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -4)),
                ],
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Quantity Control
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Icon(Icons.remove, size: 16, color: AppTheme.textPrimary),
                            ),
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                          ),
                          InkWell(
                            onTap: () => setState(() => _quantity++),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Icon(Icons.add, size: 16, color: AppTheme.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addToCart(
                            foodItem: widget.foodItem,
                            selectedSpiceLevel: _selectedSpice,
                            quantity: _quantity,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text('Added ${_quantity}x ${widget.foodItem.name} to Cart!'),
                                  ),
                                ],
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Add to Cart  ${_formatPrice(_totalPriceLkr)}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
