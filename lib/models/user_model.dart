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

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = UserRole.customer,
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    this.rewardsPoints = 350,
    this.address = 'No. 45, Galle Road, Colombo 03',
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
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      rewardsPoints: int.tryParse(json['rewardsPoints']?.toString() ?? '200') ?? 200,
      address: json['address']?.toString() ?? 'No. 45, Galle Road, Colombo 03',
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
    };
  }
}
