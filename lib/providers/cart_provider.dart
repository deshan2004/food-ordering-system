import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/promo_coupon.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String _promoCode = '';
  double _promoDiscountLkr = 0.0;
  String? _promoError;
  PromoCoupon? _appliedCoupon;

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotalLkr {
    return _items.fold(0.0, (sum, item) => sum + item.totalPriceLkr);
  }

  double get deliveryFeeLkr {
    if (_items.isEmpty) return 0.0;
    if (_appliedCoupon?.type == DiscountType.freeDelivery) return 0.0;
    return subtotalLkr >= 3500.0 ? 0.0 : 180.0;
  }

  double get discountLkr => _promoDiscountLkr;

  double get grandTotalLkr {
    double total = subtotalLkr + deliveryFeeLkr - discountLkr;
    return total > 0 ? total : 0.0;
  }

  String get promoCode => _promoCode;
  String? get promoError => _promoError;
  PromoCoupon? get appliedCoupon => _appliedCoupon;
  PromoCoupon? get promoCoupon => _appliedCoupon;

  void addToCart({
    required FoodItem foodItem,
    SpiceOption? selectedSpiceLevel,
    String specialInstructions = '',
    int quantity = 1,
  }) {
    final spiceKey = selectedSpiceLevel?.id ?? 'none';
    final uniqueId = '${foodItem.id}_$spiceKey';

    int existingIndex = _items.indexWhere((item) => item.id == uniqueId);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: uniqueId,
        foodItem: foodItem,
        selectedSpiceLevel: selectedSpiceLevel,
        specialInstructions: specialInstructions,
        quantity: quantity,
      ));
    }
    _recalculatePromo();
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    int index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      _recalculatePromo();
      notifyListeners();
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    _recalculatePromo();
    notifyListeners();
  }

  void reorderItems(List<CartItem> orderItems, {bool clearCurrentCart = false}) {
    if (clearCurrentCart) {
      _items.clear();
    }
    for (final item in orderItems) {
      addToCart(
        foodItem: item.foodItem,
        selectedSpiceLevel: item.selectedSpiceLevel,
        specialInstructions: item.specialInstructions,
        quantity: item.quantity,
      );
    }
    _recalculatePromo();
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    String cleanCode = code.trim().toUpperCase();
    _promoError = null;

    final match = PromoCoupon.availableCoupons.cast<PromoCoupon?>().firstWhere(
          (c) => c?.code == cleanCode,
          orElse: () => null,
        );

    if (match != null) {
      return applyCoupon(match);
    } else {
      _promoError = 'Invalid promo code. Tap "Offers" to view active coupons!';
      notifyListeners();
      return false;
    }
  }

  bool applyCoupon(PromoCoupon coupon) {
    _promoError = null;

    if (subtotalLkr < coupon.minOrderLkr) {
      _promoError = 'Min. order of Rs. ${coupon.minOrderLkr.toInt()} required for this coupon';
      notifyListeners();
      return false;
    }

    _appliedCoupon = coupon;
    _promoCode = coupon.code;
    _promoDiscountLkr = coupon.calculateDiscount(subtotalLkr, subtotalLkr >= 3500.0 ? 0.0 : 180.0);
    notifyListeners();
    return true;
  }

  void removePromoCode() {
    _appliedCoupon = null;
    _promoCode = '';
    _promoDiscountLkr = 0.0;
    _promoError = null;
    notifyListeners();
  }

  void _recalculatePromo() {
    if (_appliedCoupon != null) {
      if (subtotalLkr < _appliedCoupon!.minOrderLkr) {
        removePromoCode();
      } else {
        _promoDiscountLkr = _appliedCoupon!.calculateDiscount(subtotalLkr, deliveryFeeLkr);
      }
    }
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    _promoCode = '';
    _promoDiscountLkr = 0.0;
    _promoError = null;
    notifyListeners();
  }
}
