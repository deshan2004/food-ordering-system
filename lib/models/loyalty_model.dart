enum LoyaltyTier {
  silver,
  gold,
  platinum,
}

enum CoinTransactionType {
  orderEarn,
  orderRedeem,
  dailyCheckIn,
  welcomeBonus,
  tierUpgradeBonus,
}

class CoinTransaction {
  final String id;
  final String title;
  final String description;
  final int coins;
  final DateTime timestamp;
  final CoinTransactionType type;
  final String? orderId;

  CoinTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.coins,
    required this.timestamp,
    required this.type,
    this.orderId,
  });

  bool get isCredit => coins > 0;
}

extension LoyaltyTierExtension on LoyaltyTier {
  String get displayName {
    switch (this) {
      case LoyaltyTier.silver:
        return 'Silver Foodie';
      case LoyaltyTier.gold:
        return 'Gold Connoisseur';
      case LoyaltyTier.platinum:
        return 'Platinum VIP Gourmet';
    }
  }

  String get badgeEmoji {
    switch (this) {
      case LoyaltyTier.silver:
        return '🥈';
      case LoyaltyTier.gold:
        return '🥇';
      case LoyaltyTier.platinum:
        return '💎';
    }
  }

  double get earnMultiplier {
    switch (this) {
      case LoyaltyTier.silver:
        return 1.0;
      case LoyaltyTier.gold:
        return 1.5;
      case LoyaltyTier.platinum:
        return 2.0;
    }
  }

  int get requiredLifetimeCoins {
    switch (this) {
      case LoyaltyTier.silver:
        return 0;
      case LoyaltyTier.gold:
        return 500;
      case LoyaltyTier.platinum:
        return 1500;
    }
  }

  int get nextTierThreshold {
    switch (this) {
      case LoyaltyTier.silver:
        return 500;
      case LoyaltyTier.gold:
        return 1500;
      case LoyaltyTier.platinum:
        return 1500;
    }
  }

  List<String> get tierPerks {
    switch (this) {
      case LoyaltyTier.silver:
        return [
          'Earn 1 Bonchi Coin per Rs. 50 spent',
          'Access to weekly exclusive promo codes',
          'Standard live order GPS tracking',
        ];
      case LoyaltyTier.gold:
        return [
          'Earn 1.5x Coins on every single order ⚡',
          'Priority kitchen prep queue ♨️',
          'Birthday bonus 200 Bonchi Coins 🎂',
          'Free delivery on orders over Rs. 2,500',
        ];
      case LoyaltyTier.platinum:
        return [
          'Earn 2x Coins on every single order 🚀',
          'Unlimited Free Delivery on all orders 🛵',
          'VIP Customer Support dedicated line 📞',
          'Surprise Chef Special gifts with orders 🎁',
          'Instant coin redemption with zero minimum',
        ];
    }
  }
}
