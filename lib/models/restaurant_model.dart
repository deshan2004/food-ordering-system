class RestaurantModel {
  final String id;
  final String name;
  final String sinhalaName;
  final String cuisine;
  final String country;
  final String flagEmoji;
  final double rating;
  final String reviewCountText;
  final String deliveryTime;
  final double deliveryFeeLkr;
  final String address;
  final String coverImageUrl;
  final String logoUrl;
  final bool isOpenNow;
  final String badgeTag;
  final List<String> menuCategories;

  const RestaurantModel({
    required this.id,
    required this.name,
    this.sinhalaName = '',
    required this.cuisine,
    required this.country,
    required this.flagEmoji,
    required this.rating,
    required this.reviewCountText,
    required this.deliveryTime,
    required this.deliveryFeeLkr,
    required this.address,
    required this.coverImageUrl,
    required this.logoUrl,
    this.isOpenNow = true,
    this.badgeTag = '',
    required this.menuCategories,
  });
}
