import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String _promoCode = '';
  double _promoDiscountLkr = 0.0;
  String? _promoError;

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotalLkr {
    return _items.fold(0.0, (sum, item) => sum + item.totalPriceLkr);
  }

  double get deliveryFeeLkr {
    if (_items.isEmpty) return 0.0;
    return subtotalLkr >= 3500.0 ? 0.0 : 180.0;
  }

  double get discountLkr => _promoDiscountLkr;

  double get grandTotalLkr {
    double total = subtotalLkr + deliveryFeeLkr - discountLkr;
    return total > 0 ? total : 0.0;
  }

  String get promoCode => _promoCode;
  String? get promoError => _promoError;

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

  bool applyPromoCode(String code) {
    String cleanCode = code.trim().toUpperCase();
    _promoError = null;

    if (cleanCode == 'MONSOON20') {
      _promoCode = cleanCode;
      _promoDiscountLkr = subtotalLkr * 0.20;
      notifyListeners();
      return true;
    } else if (cleanCode == 'BONCHI500') {
      _promoCode = cleanCode;
      _promoDiscountLkr = 500.0;
      notifyListeners();
      return true;
    } else {
      _promoError = 'Invalid code. Try MONSOON20 or BONCHI500';
      notifyListeners();
      return false;
    }
  }

  void removePromoCode() {
    _promoCode = '';
    _promoDiscountLkr = 0.0;
    _promoError = null;
    notifyListeners();
  }

  void _recalculatePromo() {
    if (_promoCode == 'MONSOON20') {
      _promoDiscountLkr = subtotalLkr * 0.20;
    } else if (_promoCode == 'BONCHI500') {
      _promoDiscountLkr = subtotalLkr >= 500.0 ? 500.0 : subtotalLkr;
    }
  }

  void clearCart() {
    _items.clear();
    _promoCode = '';
    _promoDiscountLkr = 0.0;
    _promoError = null;
    notifyListeners();
  }
}
