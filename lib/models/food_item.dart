class SpiceOption {
  final String id;
  final String name;
  final String iconEmoji;
  final double extraPriceLkr;

  SpiceOption({
    required this.id,
    required this.name,
    required this.iconEmoji,
    this.extraPriceLkr = 0.0,
  });
}

class FoodItem {
  final String id;
  final String name;
  final String sinhalaName;
  final String restaurantName;
  final String restaurantSubtitle;
  final String description;
  final double priceLkr;
  final double rating;
  final String reviewCountText;
  final String deliveryTime;
  final double deliveryFeeLkr;
  final String category;
  final String imageUrl;
  final bool isOpenNow;
  final bool isBestseller;
  final bool isSpecial;
  final bool isHalal;
  final String servesText;
  final String signatureTag;
  final String signatureItemName;
  final double signatureItemPriceLkr;
  final List<SpiceOption> spiceLevels;

  FoodItem({
    required this.id,
    required this.name,
    this.sinhalaName = '',
    required this.restaurantName,
    this.restaurantSubtitle = '',
    required this.description,
    required this.priceLkr,
    required this.rating,
    required this.reviewCountText,
    required this.deliveryTime,
    required this.deliveryFeeLkr,
    required this.category,
    required this.imageUrl,
    this.isOpenNow = true,
    this.isBestseller = false,
    this.isSpecial = false,
    this.isHalal = true,
    this.servesText = 'Serves 1–2 • 650g',
    this.signatureTag = '',
    this.signatureItemName = '',
    this.signatureItemPriceLkr = 0.0,
    this.spiceLevels = const [],
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sinhalaName: json['sinhalaName']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? '',
      restaurantSubtitle: json['restaurantSubtitle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priceLkr: double.tryParse(json['priceLkr']?.toString() ?? '0') ?? 0.0,
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      reviewCountText: json['reviewCountText']?.toString() ?? '',
      deliveryTime: json['deliveryTime']?.toString() ?? '',
      deliveryFeeLkr: double.tryParse(json['deliveryFeeLkr']?.toString() ?? '0') ?? 0.0,
      category: json['category']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isOpenNow: json['isOpenNow'] == true || json['isOpenNow'] == 1 || json['isOpenNow'] == '1',
      isBestseller: json['isBestseller'] == true || json['isBestseller'] == 1 || json['isBestseller'] == '1',
      isSpecial: json['isSpecial'] == true || json['isSpecial'] == 1 || json['isSpecial'] == '1',
      isHalal: json['isHalal'] == true || json['isHalal'] == 1 || json['isHalal'] == '1',
      servesText: json['servesText']?.toString() ?? 'Serves 1–2 • 650g',
      signatureTag: json['signatureTag']?.toString() ?? '',
      signatureItemName: json['signatureItemName']?.toString() ?? '',
      spiceLevels: [
        SpiceOption(id: 'sp1', name: 'Mild', iconEmoji: '🍃', extraPriceLkr: 0),
        SpiceOption(id: 'sp2', name: 'Medium Spicy', iconEmoji: '🌶️', extraPriceLkr: 0),
        SpiceOption(id: 'sp3', name: 'Nai Miris Hot', iconEmoji: '🔥', extraPriceLkr: 500),
      ],
    );
  }
}
