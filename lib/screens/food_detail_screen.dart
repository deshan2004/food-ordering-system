import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';
import '../models/review_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/add_review_dialog.dart';
import '../widgets/photo_lightbox_dialog.dart';
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
  String _reviewFilter = 'all';
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
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.5),
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
                                    color: isSelected ? const Color(0xFFECFDF5).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.90),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primaryGreen : Colors.white.withValues(alpha: 0.95),
                                      width: isSelected ? 1.8 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                                    ],
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

                        const SizedBox(height: 28),

                        // Customer Reviews & Food Photos Section
                        _buildReviewsSection(context),

                        const SizedBox(height: 110),
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
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, -4)),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.5),
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _reviewFilter == value;
    return InkWell(
      onTap: () => setState(() => _reviewFilter = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        final reviews = reviewProvider.getReviewsForFood(widget.foodItem.id, filter: _reviewFilter);
        final avgRating = reviewProvider.getAverageRating(widget.foodItem.id);
        final totalCount = reviewProvider.getTotalReviewsCount(widget.foodItem.id);
        final photos = reviewProvider.getAllPhotoUrlsForFood(widget.foodItem.id);
        final distribution = reviewProvider.getRatingDistribution(widget.foodItem.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & "Write Review" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.rate_review_rounded, color: AppTheme.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Reviews & Photos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFECFDF5),
                    foregroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    AddReviewDialog.show(context, widget.foodItem, spiceLevel: _selectedSpice.name);
                  },
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                  label: const Text('Add Review ✍️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Ratings & Distribution Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Left Score
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$avgRating',
                          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, height: 1.1),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return Icon(
                              i < avgRating.floor() ? Icons.star_rounded : (i < avgRating ? Icons.star_half_rounded : Icons.star_border_rounded),
                              color: const Color(0xFFFBBF24),
                              size: 17,
                            );
                          }),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$totalCount ratings',
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  Container(height: 70, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 12)),

                  // Right Distribution Bars
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final count = distribution[star] ?? 0;
                        final totalSum = distribution.values.fold<int>(0, (a, b) => a + b);
                        final pct = totalSum > 0 ? (count / totalSum) : 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text('$star★', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      star >= 4 ? AppTheme.primaryGreen : (star == 3 ? const Color(0xFFFBBF24) : AppTheme.accentRed),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Foodie Photos Gallery Strip (if photos exist)
            if (photos.isNotEmpty) ...[
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Foodie Photos 📸 (${photos.length})',
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const Text('Tap to zoom', style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final photoUrl = photos[i];
                    return InkWell(
                      onTap: () => PhotoLightboxDialog.show(context, photoUrl, caption: '${widget.foodItem.name} photo by diner'),
                      borderRadius: BorderRadius.circular(14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          photoUrl,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 84,
                            height: 84,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All Reviews'),
                  const SizedBox(width: 8),
                  _buildFilterChip('photos', 'With Photos 📸'),
                  const SizedBox(width: 8),
                  _buildFilterChip('5star', '5 Stars ⭐'),
                  const SizedBox(width: 8),
                  _buildFilterChip('helpful', 'Most Helpful 👍'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Review Cards List
            if (reviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.rate_review_outlined, color: Colors.grey, size: 36),
                    const SizedBox(height: 8),
                    const Text('No reviews in this category yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 4),
                    Text('Be the first to review ${widget.foodItem.name}!', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              )
            else
              ...reviews.map((r) => _buildReviewCard(context, reviewProvider, r)),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewProvider provider, ReviewModel review) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author & Rating Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: review.authorAvatarUrl.isNotEmpty ? NetworkImage(review.authorAvatarUrl) : null,
                child: review.authorAvatarUrl.isEmpty
                    ? Text(
                        review.authorName.isNotEmpty ? review.authorName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerifiedOrder) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: AppTheme.primaryGreen, size: 11),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormatter.format(review.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              // Stars
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (review.dishTags.isNotEmpty || review.userSpiceLevel != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (review.userSpiceLevel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      review.userSpiceLevel!,
                      style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ...review.dishTags.map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontSize: 10.5, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // Comment Text
          Text(
            review.comment,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textPrimary),
          ),

          // Attached Photos (if any)
          if (review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final pUrl = review.photoUrls[idx];
                  return InkWell(
                    onTap: () => PhotoLightboxDialog.show(context, pUrl, caption: 'Photo by ${review.authorName}'),
                    borderRadius: BorderRadius.circular(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        pUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, color: Colors.grey, size: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Bottom Bar: Helpful Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => provider.toggleHelpful(review.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        review.isLikedByMe ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
                        size: 14,
                        color: review.isLikedByMe ? AppTheme.primaryGreen : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Helpful (${review.helpfulCount})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: review.isLikedByMe ? FontWeight.bold : FontWeight.w500,
                          color: review.isLikedByMe ? AppTheme.primaryGreen : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
