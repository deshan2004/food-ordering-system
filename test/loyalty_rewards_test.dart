import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_system/models/loyalty_model.dart';
import 'package:food_ordering_system/models/food_item.dart';
import 'package:food_ordering_system/providers/loyalty_provider.dart';
import 'package:food_ordering_system/providers/cart_provider.dart';

void main() {
  group('Bonchi Loyalty Coins & VIP Tier System Tests', () {
    late LoyaltyProvider loyalty;
    late CartProvider cart;

    setUp(() {
      loyalty = LoyaltyProvider();
      cart = CartProvider();
    });

    test('Initial state provides starting balance and Gold tier', () {
      expect(loyalty.coinsBalance, 450);
      expect(loyalty.lifetimeCoinsEarned, 720);
      expect(loyalty.currentTier, LoyaltyTier.gold);
      expect(loyalty.currentTier.earnMultiplier, 1.5);
      expect(loyalty.currentTier.displayName, 'Gold Connoisseur');
      expect(loyalty.currentTier.badgeEmoji, '🥇');
    });

    test('calculateCoinsEarnable applies correct tier multiplier', () {
      // 50 LKR = 1 base coin * 1.5 gold multiplier = 1.5 -> 2 coins
      expect(loyalty.calculateCoinsEarnable(50.0), 2);
      // 1000 LKR = 20 base coins * 1.5 = 30 coins
      expect(loyalty.calculateCoinsEarnable(1000.0), 30);
    });

    test('earnCoinsFromOrder adds coins and records transaction', () {
      final initialBalance = loyalty.coinsBalance;
      final initialTxCount = loyalty.transactions.length;

      final earned = loyalty.earnCoinsFromOrder(
        orderId: 'ORD-TEST-1',
        totalAmountLkr: 2000.0,
      );

      // 2000 / 50 * 1.5 = 60 coins
      expect(earned, 60);
      expect(loyalty.coinsBalance, initialBalance + 60);
      expect(loyalty.lifetimeCoinsEarned, 720 + 60);
      expect(loyalty.transactions.length, initialTxCount + 1);
      expect(loyalty.transactions.first.orderId, 'ORD-TEST-1');
      expect(loyalty.transactions.first.coins, 60);
      expect(loyalty.transactions.first.isCredit, true);
    });

    test('Tier upgrades to Platinum VIP Gourmet when lifetime coins >= 1500', () {
      // Add enough coins to reach 1500+ lifetime
      loyalty.earnCoinsFromOrder(
        orderId: 'ORD-BIG',
        totalAmountLkr: 26000.0, // 26000/50*1.5 = 780 coins -> 720 + 780 = 1500
      );

      expect(loyalty.currentTier, LoyaltyTier.platinum);
      expect(loyalty.currentTier.earnMultiplier, 2.0);
      expect(loyalty.currentTier.badgeEmoji, '💎');
      expect(loyalty.tierProgress, 1.0);
      expect(loyalty.coinsToNextTier, 0);
    });

    test('canRedeemCoins verifies sufficient balance', () {
      expect(loyalty.canRedeemCoins(100), true);
      expect(loyalty.canRedeemCoins(450), true);
      expect(loyalty.canRedeemCoins(500), false);
      expect(loyalty.canRedeemCoins(0), false);
      expect(loyalty.canRedeemCoins(-10), false);
    });

    test('redeemCoins deducts balance and records debit transaction', () {
      final initialBalance = loyalty.coinsBalance;
      final initialLifetime = loyalty.lifetimeCoinsEarned;

      final success = loyalty.redeemCoins(orderId: 'ORD-REDEEM-1', coins: 150);

      expect(success, true);
      expect(loyalty.coinsBalance, initialBalance - 150);
      // Lifetime coins earned shouldn't decrease when redeemed
      expect(loyalty.lifetimeCoinsEarned, initialLifetime);
      expect(loyalty.transactions.first.coins, -150);
      expect(loyalty.transactions.first.isCredit, false);
      expect(loyalty.transactions.first.type, CoinTransactionType.orderRedeem);
    });

    test('claimDailyBonus awards daily coins', () {
      expect(loyalty.canClaimDailyBonus, true);
      final initialBalance = loyalty.coinsBalance;

      final bonus = loyalty.claimDailyBonus();

      expect(bonus, 40);
      expect(loyalty.coinsBalance, initialBalance + 40);
      expect(loyalty.canClaimDailyBonus, false);

      // Trying again immediately fails
      expect(loyalty.claimDailyBonus(), 0);
    });

    test('CartProvider handles coin redemption discount alongside cart calculations', () {
      final foodItem = FoodItem(
        id: 'kottu_1',
        name: 'Chicken Cheese Kottu',
        sinhalaName: 'චිකන් චීස් කොත්තු',
        description: 'Cheesy kottu',
        priceLkr: 1500.0,
        imageUrl: 'assets/images/kottu.jpg',
        category: 'Kottu',
        country: 'Sri Lankan',
        restaurantName: 'Pilawos',
        rating: 4.8,
        reviewCountText: '120 reviews',
        deliveryTime: '20-25 min',
        deliveryFeeLkr: 180.0,
      );

      cart.addToCart(foodItem: foodItem, quantity: 1);

      expect(cart.subtotalLkr, 1500.0);
      expect(cart.deliveryFeeLkr, 180.0);
      expect(cart.discountLkr, 0.0);
      expect(cart.grandTotalLkr, 1680.0);

      // Apply 200 Bonchi coins (Rs. 200 off)
      cart.applyCoinsRedemption(200, 200.0);

      expect(cart.redeemedCoins, 200);
      expect(cart.coinDiscountLkr, 200.0);
      expect(cart.discountLkr, 200.0);
      expect(cart.grandTotalLkr, 1480.0);

      // Remove coins
      cart.removeCoinsRedemption();
      expect(cart.redeemedCoins, 0);
      expect(cart.coinDiscountLkr, 0.0);
      expect(cart.grandTotalLkr, 1680.0);

      // Clear cart resets all coin state
      cart.applyCoinsRedemption(100, 100.0);
      cart.clearCart();
      expect(cart.redeemedCoins, 0);
      expect(cart.coinDiscountLkr, 0.0);
      expect(cart.items.isEmpty, true);
    });
  });
}
