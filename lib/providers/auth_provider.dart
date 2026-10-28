import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static String get loginUrl => ApiConfig.loginUrl;
  static String get registerUrl => ApiConfig.registerUrl;
  static String get updateProfileUrl => ApiConfig.updateProfileUrl;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  UserModel createDemoUserForEmail(String email) {
    final lower = email.toLowerCase();
    if (lower.contains('restaurant') || lower.contains('kitchen') || lower.contains('hotel')) {
      return UserModel(
        id: 'usr_rest_001',
        name: 'Pilawaos Grand Hotel',
        email: email.isNotEmpty ? email : 'restaurant@bonchi.lk',
        phone: '+94 11 257 4839',
        role: UserRole.restaurant,
        address: 'No. 142, Galle Road, Colombo 03',
        latitude: 6.8992,
        longitude: 79.8550,
      );
    } else if (lower.contains('driver') || lower.contains('rider')) {
      return UserModel(
        id: 'usr_driver_001',
        name: 'Sumith Perera',
        email: email.isNotEmpty ? email : 'driver@bonchi.lk',
        phone: '+94 77 123 4567',
        role: UserRole.driver,
        address: 'Colombo 03 Central Zone',
        latitude: 6.8980,
        longitude: 79.8565,
      );
    } else if (lower.contains('admin')) {
      return UserModel(
        id: 'usr_admin_001',
        name: 'Bonchi System Admin',
        email: email.isNotEmpty ? email : 'admin@bonchi.lk',
        phone: '+94 11 999 8888',
        role: UserRole.admin,
        address: 'Bonchi HQ, World Trade Center, Colombo 01',
        latitude: 6.9344,
        longitude: 79.8428,
      );
    } else {
      return UserModel(
        id: 'usr_cust_001',
        name: 'Deshan Siriwardhana',
        email: email.isNotEmpty ? email : 'customer@bonchi.lk',
        phone: '+94 77 123 4567',
        role: UserRole.customer,
        rewardsPoints: 500,
        address: 'No. 42/1, Alfred House Gardens, Colombo 03',
        latitude: 6.8972,
        longitude: 79.8560,
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiConfig.postMultiHost(
        'login.php',
        body: {
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true && data['user'] != null) {
        _currentUser = UserModel.fromJson(data['user']);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message']?.toString() ?? 'Invalid email or password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login backend error: $e');
      _errorMessage = 'Cannot connect to database. Please make sure XAMPP Apache and MySQL are running.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    UserRole role = UserRole.customer,
    String? vehicleInfo,
    String? restaurantName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Security validation: Prevent public registration as Super Admin
    final safeRole = (role == UserRole.admin) ? UserRole.customer : role;

    try {
      final response = await ApiConfig.postMultiHost(
        'register.php',
        body: {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password.trim(),
          'role': safeRole.name,
          'vehicle_info': vehicleInfo,
          'restaurant_name': restaurantName,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true && data['user'] != null) {
        _currentUser = UserModel.fromJson(data['user']).copyWith(
          isVerified: false,
          vehicleInfo: vehicleInfo,
          restaurantName: restaurantName,
        );
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message']?.toString() ?? 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('SignUp backend error: $e');
      _errorMessage = 'Cannot connect to database. Please make sure XAMPP Apache and MySQL are running.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyAccount({required String otpCode}) async {
    _isLoading = true;
    notifyListeners();

    // Simulate OTP / Identity check verification
    await Future.delayed(const Duration(milliseconds: 600));

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isVerified: true);
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void setRole(UserRole role) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);

      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    UserRole? role,
    String? vehicleInfo,
    String? restaurantName,
  }) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        avatarUrl: avatarUrl,
        role: role,
        vehicleInfo: vehicleInfo,
        restaurantName: restaurantName,
      );
      _currentUser = updatedUser;
      notifyListeners();

      // Async save to MySQL database
      try {
        await ApiConfig.postMultiHost(
          'update_profile.php',
          body: {
            'id': updatedUser.id,
            'email': updatedUser.email,
            'name': updatedUser.name,
            'phone': updatedUser.phone,
            'address': updatedUser.address,
            'avatar_url': updatedUser.avatarUrl,
            'vehicle_info': updatedUser.vehicleInfo,
            'restaurant_name': updatedUser.restaurantName,
          },
        );
      } catch (e) {
        debugPrint('MySQL Profile Sync Note: $e');
      }
    }
  }

  void addRewardPoints(int points) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        rewardsPoints: _currentUser!.rewardsPoints + points,
      );
      notifyListeners();
    }
  }
}
