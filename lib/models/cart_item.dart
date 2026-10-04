import 'food_item.dart';

class CartItem {
  final String id;
  final FoodItem foodItem;
  final SpiceOption? selectedSpiceLevel;
  final String specialInstructions;
  int quantity;

  CartItem({
    required this.id,
    required this.foodItem,
    this.selectedSpiceLevel,
    this.specialInstructions = '',
    this.quantity = 1,
  });

  double get unitPriceLkr {
    double extra = selectedSpiceLevel?.extraPriceLkr ?? 0.0;
    return foodItem.priceLkr + extra;
  }

  double get totalPriceLkr => unitPriceLkr * quantity;
}
