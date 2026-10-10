enum UserRole {
  customer,
  restaurant,
  driver,
  admin,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String avatarUrl;
  final int rewardsPoints;
  final String address;
  final double? latitude;
  final double? longitude;

  final bool isVerified;
  final String? vehicleInfo;
  final String? restaurantName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = UserRole.customer,
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    this.rewardsPoints = 350,
    this.address = 'No. 45, Galle Road, Colombo 03',
    this.latitude,
    this.longitude,
    this.isVerified = true,
    this.vehicleInfo,
    this.restaurantName,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    int? rewardsPoints,
    String? address,
    double? latitude,
    double? longitude,
    bool? isVerified,
    String? vehicleInfo,
    String? restaurantName,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rewardsPoints: rewardsPoints ?? this.rewardsPoints,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      restaurantName: restaurantName ?? this.restaurantName,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.customer;
    final rStr = json['role']?.toString().toLowerCase() ?? 'customer';
    if (rStr == 'restaurant') parsedRole = UserRole.restaurant;
    if (rStr == 'driver') parsedRole = UserRole.driver;
    if (rStr == 'admin') parsedRole = UserRole.admin;

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: parsedRole,
      avatarUrl: (json['avatarUrl']?.toString().isNotEmpty == true)
          ? json['avatarUrl']
          : (json['avatar_url']?.toString().isNotEmpty == true)
              ? json['avatar_url']
              : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      rewardsPoints: int.tryParse(json['rewardsPoints']?.toString() ?? '200') ?? 200,
      address: json['address']?.toString() ?? 'No. 45, Galle Road, Colombo 03',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isVerified: json['isVerified'] == null || json['isVerified'] == true || json['isVerified'] == 1 || json['isVerified'] == '1',
      vehicleInfo: json['vehicleInfo']?.toString(),
      restaurantName: json['restaurantName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'rewardsPoints': rewardsPoints,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isVerified': isVerified,
      'vehicleInfo': vehicleInfo,
      'restaurantName': restaurantName,
    };
  }
}
