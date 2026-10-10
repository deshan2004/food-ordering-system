import 'package:flutter/foundation.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final List<ReviewModel> _reviews = [
    // Reviews for Chicken Cheese Kottu / Kottu dishes
    ReviewModel(
      id: 'rev_1',
      foodItemId: 'kottu_1',
      foodName: 'Chicken Cheese Kottu',
      restaurantName: 'Pilawaos Night Kottu',
      authorName: 'Dinuka Senaviratne',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      rating: 5.0,
      comment: 'Hands down the best cheese kottu in Colombo! The mozzarella pull was insane and the roast chicken was smoky and tender. Still piping hot when it arrived 🛵🔥.',
      photoUrls: [
        'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
      ],
      dishTags: ['Cheesy Pull 🧀', 'Super Hot 🔥', 'Generous Chicken 🍗'],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      helpfulCount: 24,
      isVerifiedOrder: true,
      userSpiceLevel: 'Medium Spicy 🌶️',
    ),
    ReviewModel(
      id: 'rev_2',
      foodItemId: 'kottu_1',
      foodName: 'Chicken Cheese Kottu',
      restaurantName: 'Pilawaos Night Kottu',
      authorName: 'Anuki Fernando',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      rating: 5.0,
      comment: 'Portion was huge, easily shared between two people. The gravy that came with it was rich and full of spices. Will order again every weekend!',
      photoUrls: [
        'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
      ],
      dishTags: ['Big Portion 🍛', 'Savory Gravy 🍲'],
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      helpfulCount: 15,
      isVerifiedOrder: true,
      userSpiceLevel: 'Extra Spicy 🔥',
    ),
    ReviewModel(
      id: 'rev_3',
      foodItemId: 'kottu_1',
      foodName: 'Chicken Cheese Kottu',
      restaurantName: 'Pilawaos Night Kottu',
      authorName: 'Suresh Jayawardena',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=200&q=80',
      rating: 4.5,
      comment: 'Very tasty and quick delivery! Only giving 4.5 because I asked for no onions, but there were a few. Still phenomenal quality.',
      photoUrls: [],
      dishTags: ['Fast Delivery ⚡', 'Value for Money 💰'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      helpfulCount: 8,
      isVerifiedOrder: true,
      userSpiceLevel: 'Mild Spicy 🌱',
    ),

    // Reviews for Burger dishes
    ReviewModel(
      id: 'rev_4',
      foodItemId: 'burger_1',
      foodName: 'Crispy Gourmet Burger',
      restaurantName: 'The Burger Club',
      authorName: 'Malith Perera',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=200&q=80',
      rating: 5.0,
      comment: 'The brioche bun was pillow-soft and the double beef patty was dripping with caramelized onion jam. Worth every rupee 🍔✨.',
      photoUrls: [
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=800&q=80',
      ],
      dishTags: ['Juicy Patty 🥩', 'Soft Brioche 🍞', 'Chef Signature ⭐'],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      helpfulCount: 31,
      isVerifiedOrder: true,
    ),
    ReviewModel(
      id: 'rev_5',
      foodItemId: 'burger_1',
      foodName: 'Crispy Gourmet Burger',
      restaurantName: 'The Burger Club',
      authorName: 'Chamari Silva',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      rating: 4.0,
      comment: 'Crispy fries on the side were seasoned to perfection! Burger was slightly messy to eat in the car but flavor was 10/10.',
      photoUrls: [
        'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80',
      ],
      dishTags: ['Crispy Fries 🍟', 'Super Saucy 🥫'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      helpfulCount: 12,
      isVerifiedOrder: true,
    ),

    // Reviews for Rice / Biryani / Other dishes
    ReviewModel(
      id: 'rev_6',
      foodItemId: 'rice_1',
      foodName: 'Seafood Nasi Goreng',
      restaurantName: 'Wok & Roll Asian Wok',
      authorName: 'Raveen Wickramasinghe',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      rating: 5.0,
      comment: 'Loaded with jumbo prawns and calamari rings! The sunny side egg on top had a runny yolk that mixed heavenly with the chili sambal.',
      photoUrls: [
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
      ],
      dishTags: ['Fresh Prawns 🦐', 'Runny Egg 🍳', 'Authentic Sambal 🌶️'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      helpfulCount: 19,
      isVerifiedOrder: true,
    ),
  ];

  // Preset food sample photos that customers can pick when adding simulated photo reviews
  static const List<Map<String, String>> sampleFoodPhotos = [
    {
      'title': 'Crispy Kottu Plate',
      'url': 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Cheesy Melt Pull',
      'url': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Gourmet Burger Box',
      'url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Golden Crispy Fries',
      'url': 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Claypot Seafood Rice',
      'url': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Woodfire Pizza Slice',
      'url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Sweet Faluda Shake',
      'url': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=800&q=80',
    },
  ];

  List<ReviewModel> get allReviews => List.unmodifiable(_reviews);

  /// Return reviews for a specific food item or fall back to generic culinary reviews
  List<ReviewModel> getReviewsForFood(String foodItemId, {String filter = 'all'}) {
    // If specific reviews exist for this food item, return them; otherwise provide relevant items
    var list = _reviews.where((r) => r.foodItemId == foodItemId).toList();
    if (list.isEmpty) {
      // Fallback matching by category or show sample high quality reviews so user sees rich experience
      list = _reviews.take(3).toList();
    }

    switch (filter) {
      case 'photos':
        return list.where((r) => r.photoUrls.isNotEmpty).toList();
      case '5star':
        return list.where((r) => r.rating >= 4.8).toList();
      case 'helpful':
        final sorted = List<ReviewModel>.from(list);
        sorted.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        return sorted;
      case 'all':
      default:
        return list;
    }
  }

  double getAverageRating(String foodItemId) {
    final list = _reviews.where((r) => r.foodItemId == foodItemId).toList();
    if (list.isEmpty) return 4.9;
    final sum = list.fold<double>(0.0, (acc, r) => acc + r.rating);
    return double.parse((sum / list.length).toStringAsFixed(1));
  }

  int getTotalReviewsCount(String foodItemId) {
    final count = _reviews.where((r) => r.foodItemId == foodItemId).length;
    return count > 0 ? count : 42;
  }

  int getPhotosCount(String foodItemId) {
    final list = _reviews.where((r) => r.foodItemId == foodItemId).toList();
    if (list.isEmpty) return 18;
    return list.fold<int>(0, (sum, r) => sum + r.photoUrls.length);
  }

  Map<int, int> getRatingDistribution(String foodItemId) {
    final list = _reviews.where((r) => r.foodItemId == foodItemId).toList();
    if (list.isEmpty) {
      return {5: 78, 4: 16, 3: 4, 2: 1, 1: 1};
    }

    final Map<int, int> dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in list) {
      final star = r.rating.round().clamp(1, 5);
      dist[star] = (dist[star] ?? 0) + 1;
    }
    return dist;
  }

  List<String> getAllPhotoUrlsForFood(String foodItemId) {
    final list = _reviews.where((r) => r.foodItemId == foodItemId).toList();
    final photos = <String>[];
    for (var r in list) {
      photos.addAll(r.photoUrls);
    }
    if (photos.isEmpty) {
      return sampleFoodPhotos.take(4).map((m) => m['url']!).toList();
    }
    return photos;
  }

  void addReview({
    required String foodItemId,
    required String foodName,
    required String restaurantName,
    required String authorName,
    required double rating,
    required String comment,
    List<String> photoUrls = const [],
    List<String> dishTags = const [],
    String? userSpiceLevel,
  }) {
    final newReview = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      foodItemId: foodItemId,
      foodName: foodName,
      restaurantName: restaurantName,
      authorName: authorName,
      authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      rating: rating,
      comment: comment,
      photoUrls: photoUrls,
      dishTags: dishTags,
      createdAt: DateTime.now(),
      helpfulCount: 0,
      isVerifiedOrder: true,
      userSpiceLevel: userSpiceLevel,
    );

    _reviews.insert(0, newReview);
    notifyListeners();
  }

  void toggleHelpful(String reviewId) {
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx != -1) {
      final r = _reviews[idx];
      if (r.isLikedByMe) {
        r.isLikedByMe = false;
        r.helpfulCount = (r.helpfulCount - 1).clamp(0, 9999);
      } else {
        r.isLikedByMe = true;
        r.helpfulCount += 1;
      }
      notifyListeners();
    }
  }
}
