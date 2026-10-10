import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser = UserModel(
    id: 'usr_cust_001',
    name: 'Deshan Siriwardhana',
    email: 'customer@bonchi.lk',
    phone: '+94 77 123 4567',
    role: UserRole.customer,
    rewardsPoints: 500,
    address: 'No. 42/1, Alfred House Gardens, Colombo 03',
    latitude: 6.8972,
    longitude: 79.8560,
  );
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static String get host {
    if (!kIsWeb && Platform.isAndroid) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  static String get loginUrl => 'http://$host/food_api/login.php';
  static String get registerUrl => 'http://$host/food_api/register.php';

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
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      ).timeout(const Duration(milliseconds: 1500));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        _currentUser = UserModel.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login backend unreachable, using seamless demo auth: $e');
    }

    // Seamless instant login with role-specific demo user
    _currentUser = createDemoUserForEmail(email.trim());
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password.trim(),
        }),
      ).timeout(const Duration(milliseconds: 1500));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        _currentUser = UserModel.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('SignUp backend unreachable, using seamless demo auth: $e');
    }

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isNotEmpty ? name.trim() : 'Deshan Siriwardhana',
      email: email.trim().isNotEmpty ? email.trim() : 'customer@bonchi.lk',
      phone: phone.trim().isNotEmpty ? phone.trim() : '+94 77 123 4567',
      role: UserRole.customer,
      rewardsPoints: 200,
      address: 'No. 42/1, Alfred House Gardens, Colombo 03',
      latitude: 6.8972,
      longitude: 79.8560,
    );
    _isLoading = false;
    _errorMessage = null;
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

  void updateProfile({
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? avatarUrl,
    UserRole? role,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        avatarUrl: avatarUrl,
        role: role,
      );
      notifyListeners();
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
