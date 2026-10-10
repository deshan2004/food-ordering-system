import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_system/models/cart_item.dart';
import 'package:food_ordering_system/providers/cart_provider.dart';
import 'package:food_ordering_system/providers/favorites_provider.dart';
import 'package:food_ordering_system/services/food_service.dart';

void main() {
  group('Favorites Provider Tests', () {
    late FavoritesProvider favProvider;

    setUp(() {
      favProvider = FavoritesProvider();
    });

    test('Initial favorites contains default signature items', () {
      expect(favProvider.isFavorite('b1'), isTrue);
      expect(favProvider.isFavorite('b2'), isTrue);
      expect(favProvider.favoriteFoodItems.length, greaterThanOrEqualTo(2));
    });

    test('Toggling favorite adds and removes item', () {
      final sampleItem = FoodService.mockFoodItems.first;
      expect(favProvider.isFavorite(sampleItem.id), isTrue);

      favProvider.toggleFavorite(sampleItem);
      expect(favProvider.isFavorite(sampleItem.id), isFalse);

      favProvider.toggleFavorite(sampleItem);
      expect(favProvider.isFavorite(sampleItem.id), isTrue);
    });

    test('Clear all favorites empties the list', () {
      expect(favProvider.favoriteIds, isNotEmpty);
      favProvider.clearAllFavorites();
      expect(favProvider.favoriteIds, isEmpty);
      expect(favProvider.favoriteFoodItems, isEmpty);
    });
  });

  group('Cart Provider 1-Tap Re-Order Tests', () {
    late CartProvider cart;
    final item1 = FoodService.mockFoodItems[0];
    final item2 = FoodService.mockFoodItems[1];

    setUp(() {
      cart = CartProvider();
    });

    test('reorderItems populates cart with exact items and quantities', () {
      final orderItems = [
        CartItem(id: 'c1', foodItem: item1, quantity: 2),
        CartItem(id: 'c2', foodItem: item2, quantity: 1),
      ];

      cart.reorderItems(orderItems);

      expect(cart.totalItemCount, 3);
      expect(cart.subtotalLkr, (item1.priceLkr * 2) + item2.priceLkr);
    });

    test('reorderItems with clearCurrentCart resets existing items before adding', () {
      // First put an existing item
      cart.addToCart(foodItem: item1, quantity: 5);
      expect(cart.totalItemCount, 5);

      final newOrderItems = [
        CartItem(id: 'c2', foodItem: item2, quantity: 2),
      ];

      cart.reorderItems(newOrderItems, clearCurrentCart: true);

      expect(cart.totalItemCount, 2);
      expect(cart.items.first.foodItem.id, item2.id);
    });
  });
}
