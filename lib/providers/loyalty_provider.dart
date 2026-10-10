import 'package:flutter/foundation.dart';
import '../models/loyalty_model.dart';
export '../models/loyalty_model.dart';

class LoyaltyProvider with ChangeNotifier {
  int _coinsBalance = 450;
  int _lifetimeCoinsEarned = 720;
  DateTime? _lastDailyCheckIn;

  final List<CoinTransaction> _transactions = [
    CoinTransaction(
      id: 'tx_welcome',
      title: 'Welcome Bonus 🎁',
      description: 'Bonchi Rewards club joining gift',
      coins: 200,
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
      type: CoinTransactionType.welcomeBonus,
    ),
    CoinTransaction(
      id: 'tx_ord_1',
      title: 'Order Reward #ORD-9821 🍛',
      description: 'Chicken Cheese Kottu & Milo packet',
      coins: 65,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      type: CoinTransactionType.orderEarn,
      orderId: 'ORD-9821',
    ),
    CoinTransaction(
      id: 'tx_checkin_1',
      title: 'Daily Streak Mystery Box ⚡',
      description: 'Day 3 check-in bonus reward',
      coins: 35,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: CoinTransactionType.dailyCheckIn,
    ),
    CoinTransaction(
      id: 'tx_ord_2',
      title: 'Order Reward #ORD-9844 🍔',
      description: 'Double Beef Burger & Peri-Peri Fries',
      coins: 150,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: CoinTransactionType.orderEarn,
      orderId: 'ORD-9844',
    ),
  ];

  int get coinsBalance => _coinsBalance;
  int get lifetimeCoinsEarned => _lifetimeCoinsEarned;
  List<CoinTransaction> get transactions => List.unmodifiable(_transactions);
  DateTime? get lastDailyCheckIn => _lastDailyCheckIn;

  LoyaltyTier get currentTier {
    if (_lifetimeCoinsEarned >= 1500) {
      return LoyaltyTier.platinum;
    } else if (_lifetimeCoinsEarned >= 500) {
      return LoyaltyTier.gold;
    }
    return LoyaltyTier.silver;
  }

  double get tierProgress {
    switch (currentTier) {
      case LoyaltyTier.silver:
        return (_lifetimeCoinsEarned / 500.0).clamp(0.0, 1.0);
      case LoyaltyTier.gold:
        return ((_lifetimeCoinsEarned - 500.0) / 1000.0).clamp(0.0, 1.0);
      case LoyaltyTier.platinum:
        return 1.0;
    }
  }

  int get coinsToNextTier {
    switch (currentTier) {
      case LoyaltyTier.silver:
        return (500 - _lifetimeCoinsEarned).clamp(0, 500);
      case LoyaltyTier.gold:
        return (1500 - _lifetimeCoinsEarned).clamp(0, 1000);
      case LoyaltyTier.platinum:
        return 0;
    }
  }

  int calculateCoinsEarnable(double totalAmountLkr) {
    if (totalAmountLkr <= 0) return 0;
    final base = (totalAmountLkr / 50.0);
    return (base * currentTier.earnMultiplier).round();
  }

  int earnCoinsFromOrder({required String orderId, required double totalAmountLkr}) {
    final earned = calculateCoinsEarnable(totalAmountLkr);
    if (earned <= 0) return 0;

    _coinsBalance += earned;
    _lifetimeCoinsEarned += earned;

    _transactions.insert(
      0,
      CoinTransaction(
        id: 'tx_ord_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Order Reward #$orderId 🪙',
        description: 'Earned ${currentTier.earnMultiplier}x coins from meal purchase',
        coins: earned,
        timestamp: DateTime.now(),
        type: CoinTransactionType.orderEarn,
        orderId: orderId,
      ),
    );

    notifyListeners();
    return earned;
  }

  bool canRedeemCoins(int coins) {
    return coins > 0 && coins <= _coinsBalance;
  }

  bool redeemCoins({required String orderId, required int coins}) {
    if (!canRedeemCoins(coins)) return false;

    _coinsBalance -= coins;

    _transactions.insert(
      0,
      CoinTransaction(
        id: 'tx_redeem_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Redeemed at Checkout #$orderId 🏷️',
        description: 'Redeemed $coins coins for Rs. $coins discount',
        coins: -coins,
        timestamp: DateTime.now(),
        type: CoinTransactionType.orderRedeem,
        orderId: orderId,
      ),
    );

    notifyListeners();
    return true;
  }

  bool get canClaimDailyBonus {
    if (_lastDailyCheckIn == null) return true;
    final now = DateTime.now();
    return now.difference(_lastDailyCheckIn!).inHours >= 20;
  }

  int claimDailyBonus() {
    if (!canClaimDailyBonus) return 0;

    const bonus = 40;
    _coinsBalance += bonus;
    _lifetimeCoinsEarned += bonus;
    _lastDailyCheckIn = DateTime.now();

    _transactions.insert(
      0,
      CoinTransaction(
        id: 'tx_checkin_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Daily Streak Check-in 🌟',
        description: 'Claimed 40 Bonchi Coins daily reward',
        coins: bonus,
        timestamp: DateTime.now(),
        type: CoinTransactionType.dailyCheckIn,
      ),
    );

    notifyListeners();
    return bonus;
  }
}
