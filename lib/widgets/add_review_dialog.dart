import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/review_provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AddReviewDialog extends StatefulWidget {
  final FoodItem foodItem;
  final String? initialSpiceLevel;

  const AddReviewDialog({
    super.key,
    required this.foodItem,
    this.initialSpiceLevel,
  });

  static Future<void> show(BuildContext context, FoodItem foodItem, {String? spiceLevel}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddReviewDialog(foodItem: foodItem, initialSpiceLevel: spiceLevel),
    );
  }

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  final Set<String> _selectedTags = {'Super Fresh ♨️', 'Delicious Taste 😋'};
  final List<String> _attachedPhotos = [];

  final List<String> _availableTags = [
    'Super Fresh ♨️',
    'Delicious Taste 😋',
    'Cheesy Pull 🧀',
    'Perfect Spice 🌶️',
    'Crispy Texture 🍗',
    'Big Portion 🍛',
    'Value for Money 💰',
    'Fast & Hot ⚡',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _showPhotoPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Food Photo 📸',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Text(
              'Attach authentic photos of your dish to help fellow foodies!',
              style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ReviewProvider.sampleFoodPhotos.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (ctx, index) {
                  final photo = ReviewProvider.sampleFoodPhotos[index];
                  final url = photo['url']!;
                  final isAlreadyAttached = _attachedPhotos.contains(url);

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        if (!isAlreadyAttached) {
                          _attachedPhotos.add(url);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            url,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isAlreadyAttached)
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              photo['title']!,
                              style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  void _submitReview() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a brief comment describing your food experience!'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final authorName = auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name : 'Deshan Siriwardhana';

    reviewProvider.addReview(
      foodItemId: widget.foodItem.id,
      foodName: widget.foodItem.name,
      restaurantName: widget.foodItem.restaurantName,
      authorName: authorName,
      rating: _rating,
      comment: comment,
      photoUrls: List.from(_attachedPhotos),
      dishTags: _selectedTags.toList(),
      userSpiceLevel: widget.initialSpiceLevel,
    );

    // Reward Loyalty coins for photo review (+25 coins) or text review (+10 coins)
    final coinsEarned = _attachedPhotos.isNotEmpty ? 25 : 10;
    loyaltyProvider.claimDailyBonus(); // ensures balance is interactive or custom bonus

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Review posted! You earned +$coinsEarned Bonchi Loyalty Coins 🪙✨',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),

              // Title and Item info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.foodItem.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.foodItem.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.foodItem.restaurantName} • Verified Foodie Review',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Star Rating Selector
              Center(
                child: Column(
                  children: [
                    Text(
                      _rating >= 5.0
                          ? 'Exceptional! 🌟'
                          : _rating >= 4.0
                              ? 'Very Good! 👍'
                              : _rating >= 3.0
                                  ? 'Average 😐'
                                  : 'Needs Improvement 😕',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starVal = index + 1.0;
                        final isFilled = starVal <= _rating;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _rating = starVal;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 38,
                              color: isFilled ? const Color(0xFFFBBF24) : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Quick Tag Pills
              const Text('What stood out most? 🏷️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                    selected: isSelected,
                    onSelected: (_) => _toggleTag(tag),
                    selectedColor: const Color(0xFFECFDF5),
                    checkmarkColor: AppTheme.primaryGreen,
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: BorderSide(color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Comment Input
              const Text('Your Detailed Review ✍️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe taste, crispiness, sauce, and presentation...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5)),
                ),
              ),

              const SizedBox(height: 16),

              // Photo Attachments Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Attach Food Photos 📸', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Text('🪙 +25 Coins Bonus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 72,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add Photo Button
                    InkWell(
                      onTap: _showPhotoPickerSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryGreen, style: BorderStyle.solid, width: 1.2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryGreen, size: 22),
                            SizedBox(height: 3),
                            Text('Add Photo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Attached Photo Thumbnails
                    ..._attachedPhotos.map(
                      (url) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 72,
                        height: 72,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: InkWell(
                                onTap: () => setState(() => _attachedPhotos.remove(url)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  onPressed: _submitReview,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    'Post Review & Collect Coins ⭐',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
