import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_system/providers/review_provider.dart';

void main() {
  group('ReviewProvider Unit Tests', () {
    late ReviewProvider reviewProvider;

    setUp(() {
      reviewProvider = ReviewProvider();
    });

    test('Initial reviews are populated with verified badges and photos', () {
      final reviews = reviewProvider.allReviews;
      expect(reviews.isNotEmpty, true);

      final kottuReviews = reviewProvider.getReviewsForFood('kottu_1');
      expect(kottuReviews.isNotEmpty, true);
      expect(kottuReviews.first.isVerifiedOrder, true);
      expect(kottuReviews.first.photoUrls.isNotEmpty, true);
    });

    test('getAverageRating returns accurate average for dish', () {
      final avg = reviewProvider.getAverageRating('kottu_1');
      expect(avg, greaterThanOrEqualTo(4.5));
      expect(avg, lessThanOrEqualTo(5.0));
    });

    test('getRatingDistribution returns counts for 1-5 stars', () {
      final dist = reviewProvider.getRatingDistribution('kottu_1');
      expect(dist.containsKey(5), true);
      expect(dist.containsKey(4), true);
      expect(dist.containsKey(3), true);
      expect(dist.containsKey(2), true);
      expect(dist.containsKey(1), true);
      expect(dist[5]!, greaterThanOrEqualTo(1));
    });

    test('Filter by "photos" returns only reviews with attached photos', () {
      final photoReviews = reviewProvider.getReviewsForFood('kottu_1', filter: 'photos');
      expect(photoReviews.isNotEmpty, true);
      for (final r in photoReviews) {
        expect(r.photoUrls.isNotEmpty, true);
      }
    });

    test('Filter by "helpful" returns reviews sorted by helpful count descending', () {
      final helpfulReviews = reviewProvider.getReviewsForFood('kottu_1', filter: 'helpful');
      expect(helpfulReviews.length, greaterThanOrEqualTo(2));
      for (int i = 0; i < helpfulReviews.length - 1; i++) {
        expect(helpfulReviews[i].helpfulCount, greaterThanOrEqualTo(helpfulReviews[i + 1].helpfulCount));
      }
    });

    test('addReview adds new review to top of the list and updates counts', () {
      final initialCount = reviewProvider.allReviews.length;

      reviewProvider.addReview(
        foodItemId: 'test_dish_99',
        foodName: 'Hot Butter Cuttlefish',
        restaurantName: 'Wok Master',
        authorName: 'Kasun Dias',
        rating: 5.0,
        comment: 'Crispy and fiery red cuttlefish with green chilies! 10/10.',
        photoUrls: ['https://example.com/cuttlefish.jpg'],
        dishTags: ['Crispy Texture 🍗', 'Super Fresh ♨️'],
        userSpiceLevel: 'Extra Spicy 🔥',
      );

      expect(reviewProvider.allReviews.length, initialCount + 1);

      final added = reviewProvider.allReviews.first;
      expect(added.foodItemId, 'test_dish_99');
      expect(added.foodName, 'Hot Butter Cuttlefish');
      expect(added.authorName, 'Kasun Dias');
      expect(added.rating, 5.0);
      expect(added.photoUrls.length, 1);
      expect(added.dishTags.contains('Crispy Texture 🍗'), true);
      expect(added.userSpiceLevel, 'Extra Spicy 🔥');
      expect(added.isVerifiedOrder, true);
    });

    test('toggleHelpful increments count and marks liked, then decrements on second tap', () {
      final reviewId = reviewProvider.allReviews.first.id;
      final initialHelpful = reviewProvider.allReviews.first.helpfulCount;
      expect(reviewProvider.allReviews.first.isLikedByMe, false);

      // Tap 1: Like / helpful
      reviewProvider.toggleHelpful(reviewId);
      final likedReview = reviewProvider.allReviews.firstWhere((r) => r.id == reviewId);
      expect(likedReview.isLikedByMe, true);
      expect(likedReview.helpfulCount, initialHelpful + 1);

      // Tap 2: Unlike
      reviewProvider.toggleHelpful(reviewId);
      final unlikedReview = reviewProvider.allReviews.firstWhere((r) => r.id == reviewId);
      expect(unlikedReview.isLikedByMe, false);
      expect(unlikedReview.helpfulCount, initialHelpful);
    });
  });
}
