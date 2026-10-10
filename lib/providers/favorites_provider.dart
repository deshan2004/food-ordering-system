import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/food_service.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {'b1', 'b2'}; // Default pre-favorited signature items

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String foodId) {
    return _favoriteIds.contains(foodId);
  }

  void toggleFavorite(FoodItem foodItem) {
    if (_favoriteIds.contains(foodItem.id)) {
      _favoriteIds.remove(foodItem.id);
    } else {
      _favoriteIds.add(foodItem.id);
    }
    notifyListeners();
  }

  void addFavorite(String foodId) {
    if (_favoriteIds.add(foodId)) {
      notifyListeners();
    }
  }

  void removeFavorite(String foodId) {
    if (_favoriteIds.remove(foodId)) {
      notifyListeners();
    }
  }

  void clearAllFavorites() {
    _favoriteIds.clear();
    notifyListeners();
  }

  List<FoodItem> get favoriteFoodItems {
    return FoodService.mockFoodItems
        .where((item) => _favoriteIds.contains(item.id))
        .toList();
  }
}
