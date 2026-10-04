import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {'f1', 'f3'}; // Default pre-favorited items

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
}
