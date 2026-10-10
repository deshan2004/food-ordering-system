class ReviewModel {
  final String id;
  final String foodItemId;
  final String foodName;
  final String restaurantName;
  final String authorName;
  final String authorAvatarUrl;
  final double rating;
  final String comment;
  final List<String> photoUrls;
  final List<String> dishTags;
  final DateTime createdAt;
  int helpfulCount;
  final bool isVerifiedOrder;
  bool isLikedByMe;
  final String? userSpiceLevel;

  ReviewModel({
    required this.id,
    required this.foodItemId,
    required this.foodName,
    required this.restaurantName,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.rating,
    required this.comment,
    this.photoUrls = const [],
    this.dishTags = const [],
    required this.createdAt,
    this.helpfulCount = 0,
    this.isVerifiedOrder = true,
    this.isLikedByMe = false,
    this.userSpiceLevel,
  });

  ReviewModel copyWith({
    String? id,
    String? foodItemId,
    String? foodName,
    String? restaurantName,
    String? authorName,
    String? authorAvatarUrl,
    double? rating,
    String? comment,
    List<String>? photoUrls,
    List<String>? dishTags,
    DateTime? createdAt,
    int? helpfulCount,
    bool? isVerifiedOrder,
    bool? isLikedByMe,
    String? userSpiceLevel,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      foodItemId: foodItemId ?? this.foodItemId,
      foodName: foodName ?? this.foodName,
      restaurantName: restaurantName ?? this.restaurantName,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photoUrls: photoUrls ?? this.photoUrls,
      dishTags: dishTags ?? this.dishTags,
      createdAt: createdAt ?? this.createdAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isVerifiedOrder: isVerifiedOrder ?? this.isVerifiedOrder,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      userSpiceLevel: userSpiceLevel ?? this.userSpiceLevel,
    );
  }
}
