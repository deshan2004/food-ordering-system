enum DiscountType {
  percentage,
  flat,
  freeDelivery,
}

class PromoCoupon {
  final String code;
  final String title;
  final String description;
  final DiscountType type;
  final double value;
  final double minOrderLkr;
  final String badgeText;

  const PromoCoupon({
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderLkr = 0,
    required this.badgeText,
  });

  double calculateDiscount(double subtotal, double deliveryFee) {
    if (subtotal < minOrderLkr) return 0.0;
    switch (type) {
      case DiscountType.percentage:
        return (subtotal * (value / 100.0));
      case DiscountType.flat:
        return value > subtotal ? subtotal : value;
      case DiscountType.freeDelivery:
        return deliveryFee;
    }
  }

  static const List<PromoCoupon> availableCoupons = [
    PromoCoupon(
      code: 'BONCHI50',
      title: '50% Off Flash Feast',
      description: 'Get an incredible 50% discount on orders above Rs. 2,000!',
      type: DiscountType.percentage,
      value: 50.0,
      minOrderLkr: 2000.0,
      badgeText: '50% OFF',
    ),
    PromoCoupon(
      code: 'FREEDELIVERY',
      title: 'Zero Delivery Fee',
      description: 'Enjoy free delivery straight to your doorstep across Colombo.',
      type: DiscountType.freeDelivery,
      value: 0.0,
      badgeText: 'FREE DELIVERY',
    ),
    PromoCoupon(
      code: 'WELCOME250',
      title: 'Rs. 250 New User Treat',
      description: 'Save flat Rs. 250 on orders above Rs. 800 with Bonchi.',
      type: DiscountType.flat,
      value: 250.0,
      minOrderLkr: 800.0,
      badgeText: 'RS. 250 OFF',
    ),
    PromoCoupon(
      code: 'SAVE20',
      title: '20% Weekend Celebration',
      description: '20% off on special rice & curry, kottu, and noodles.',
      type: DiscountType.percentage,
      value: 20.0,
      badgeText: '20% OFF',
    ),
    PromoCoupon(
      code: 'MONSOON20',
      title: '20% Monsoon Specials',
      description: '20% discount on hot curries and comfort food.',
      type: DiscountType.percentage,
      value: 20.0,
      badgeText: '20% OFF',
    ),
  ];
}
