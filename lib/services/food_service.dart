import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class FoodService {
  static final List<Map<String, dynamic>> categories = [
    {'name': 'Rice & Curry', 'icon': '🍚', 'badge': 'Top Pick'},
    {'name': 'Kottu Mania', 'icon': '🍳', 'badge': 'Hot 🔥'},
    {'name': 'Short Eats', 'icon': '🥟', 'badge': ''},
    {'name': 'Biryani Feast', 'icon': '🍲', 'badge': ''},
    {'name': 'Cafe & Milk', 'icon': '☕', 'badge': ''},
  ];

  static final List<SpiceOption> bonchiSpiceOptions = [
    SpiceOption(id: 'sp1', name: 'Mild', iconEmoji: '🍃', extraPriceLkr: 0),
    SpiceOption(id: 'sp2', name: 'Medium Spicy', iconEmoji: '🌶️', extraPriceLkr: 0),
    SpiceOption(id: 'sp3', name: 'Nai Miris Hot', iconEmoji: '🔥', extraPriceLkr: 500),
  ];

  static final List<FoodItem> mockFoodItems = [
    FoodItem(
      id: 'b1',
      name: 'Chicken Cheese Kottu',
      sinhalaName: 'චිකන් චීස් කොත්තු',
      restaurantName: 'Pilawaos Grand Hotel',
      restaurantSubtitle: 'Sri Lankan • Kottu & Roti • Halal • Late Night',
      description: 'Chopped godamba roti tossed on hot griddle with spiced tender roast chicken, farm-fresh eggs, leeks, carrots, rich curry gravy, and crowned with bubbling melted mozzarella cheese.',
      priceLkr: 2100.0,
      rating: 4.9,
      reviewCountText: '3.2k+',
      deliveryTime: '20-25 min',
      deliveryFeeLkr: 150.0,
      category: 'Kottu Mania',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
      isOpenNow: true,
      isBestseller: true,
      isSpecial: true,
      isHalal: true,
      servesText: 'Serves 1–2 • 650g',
      signatureTag: 'SIGNATURE HIT',
      signatureItemName: 'Chicken Cheese Kottu',
      signatureItemPriceLkr: 1250.0,
      spiceLevels: bonchiSpiceOptions,
    ),
    FoodItem(
      id: 'b2',
      name: 'Claypot Red Rice Feast',
      sinhalaName: 'මැටි වළං රතු බත් සමග මාලු',
      restaurantName: "Upali's by Nawaloka",
      restaurantSubtitle: 'Traditional Rice & Curry • Village Style • Seafood',
      description: 'Steaming organic red kakulu rice served in authentic claypot with Jaffna crab curry, pol sambol, fried dried fish, brinjal moju, and gotukola sambol.',
      priceLkr: 2450.0,
      rating: 4.8,
      reviewCountText: '2.1k+',
      deliveryTime: '30-35 min',
      deliveryFeeLkr: 180.0,
      category: 'Rice & Curry',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
      isOpenNow: true,
      isBestseller: true,
      isSpecial: false,
      isHalal: true,
      servesText: 'Serves 2 • 800g',
      signatureTag: 'VILLAGE SPECIAL',
      signatureItemName: 'Claypot Red Rice Feast',
      signatureItemPriceLkr: 950.0,
      spiceLevels: bonchiSpiceOptions,
    ),
    FoodItem(
      id: 'b3',
      name: 'Spicy Mutton Roll (Box of 4)',
      sinhalaName: 'සැර එළුමස් රෝල්ස්',
      restaurantName: 'Sponge Pastry Shop',
      restaurantSubtitle: 'Short Eats • Bakery • Patties & Rolls • Snacks',
      description: 'Golden crispy crumbed rolls filled with slow-cooked shredded devilled mutton, potatoes, and Sri Lankan black pepper spices.',
      priceLkr: 1200.0,
      rating: 4.7,
      reviewCountText: '1.8k+',
      deliveryTime: '15-20 min',
      deliveryFeeLkr: 120.0,
      category: 'Short Eats',
      imageUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=800&q=80',
      isOpenNow: true,
      isBestseller: false,
      isSpecial: false,
      isHalal: true,
      servesText: 'Box of 4 Rolls',
      signatureTag: 'TEA TIME CRAVING',
      signatureItemName: 'Spicy Mutton Roll (Box of 4)',
      signatureItemPriceLkr: 880.0,
      spiceLevels: bonchiSpiceOptions,
    ),
  ];

  static List<FoodItem> getItemsByCategory(String categoryName) {
    if (categoryName == 'All') return mockFoodItems;
    return mockFoodItems.where((item) => item.category == categoryName).toList();
  }

  static List<FoodItem> searchItems(String query) {
    if (query.isEmpty) return mockFoodItems;
    final lower = query.toLowerCase();
    return mockFoodItems.where((item) {
      return item.name.toLowerCase().contains(lower) ||
          item.restaurantName.toLowerCase().contains(lower) ||
          item.description.toLowerCase().contains(lower) ||
          item.category.toLowerCase().contains(lower);
    }).toList();
  }

  static const String apiUrl = 'http://localhost/food_api/get_foods.php';

  static Future<List<FoodItem>> fetchFoodItemsFromApi() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((item) => FoodItem.fromJson(item)).toList();
      } else {
        return mockFoodItems;
      }
    } catch (e) {
      print('MySQL API connection error: $e');
      return mockFoodItems;
    }
  }
}
