import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_system/models/food_item.dart';
import 'package:food_ordering_system/providers/cart_provider.dart';

void main() {
  group('Promo Coupons and Cart Provider Tests', () {
    late CartProvider cart;
    final sampleFood = FoodItem(
      id: 'food_1',
      name: 'Chicken Cheese Kottu',
      restaurantName: 'Pilawaos Night Kottu',
      description: 'Cheesy kottu with chicken',
      priceLkr: 1200.0,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
      category: 'Kottu',
      rating: 4.8,
      reviewCountText: '1.2k',
      deliveryTime: '20-25 min',
      deliveryFeeLkr: 180.0,
    );

    setUp(() {
      cart = CartProvider();
    });

    test('Initial cart has zero discounts and empty promo code', () {
      expect(cart.promoCode, isEmpty);
      expect(cart.discountLkr, 0.0);
      expect(cart.promoCoupon, isNull);
    });

    test('Applies WELCOME250 fixed discount successfully', () {
      cart.addToCart(foodItem: sampleFood, quantity: 1); // 1200 LKR
      final success = cart.applyPromoCode('WELCOME250');

      expect(success, isTrue);
      expect(cart.promoCode, 'WELCOME250');
      expect(cart.discountLkr, 250.0);
      expect(cart.appliedCoupon?.code, 'WELCOME250');
    });

    test('Applies SAVE20 percentage discount with maximum cap', () {
      cart.addToCart(foodItem: sampleFood, quantity: 2); // 2400 LKR
      final success = cart.applyPromoCode('SAVE20'); // 20% of 2400 is 480, capped at 600

      expect(success, isTrue);
      expect(cart.discountLkr, 480.0);
    });

    test('Applies FREEDELIVERY coupon and waives delivery fee', () {
      cart.addToCart(foodItem: sampleFood, quantity: 1); // 1200 LKR (under 3500 standard free threshold)
      expect(cart.deliveryFeeLkr, 180.0);

      final success = cart.applyPromoCode('FREEDELIVERY');
      expect(success, isTrue);
      expect(cart.deliveryFeeLkr, 0.0);
    });

    test('Rejects coupon if subtotal is below minimum order requirement', () {
      cart.addToCart(foodItem: sampleFood, quantity: 1); // 1200 LKR (below 2500 for BONCHI50)
      final success = cart.applyPromoCode('BONCHI50');

      expect(success, isFalse);
      expect(cart.promoError, contains('Min. order'));
      expect(cart.discountLkr, 0.0);
    });

    test('Removing promo code resets discount', () {
      cart.addToCart(foodItem: sampleFood, quantity: 1);
      cart.applyPromoCode('WELCOME250');
      expect(cart.discountLkr, 250.0);

      cart.removePromoCode();
      expect(cart.promoCode, isEmpty);
      expect(cart.discountLkr, 0.0);
      expect(cart.promoCoupon, isNull);
    });
  });
}
