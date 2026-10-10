import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Local network IP address of your Mac hosting the XAMPP MySQL/PHP server
  /// (Change here if your Wi-Fi router assigns a different IP address)
  static const String serverIp = '192.168.1.5';

  static String get host {
    if (kIsWeb) {
      return 'localhost';
    }
    // On both physical devices and simulators connected to local Wi-Fi,
    // serverIp connects directly to the Mac's Apache/PHP & MySQL server.
    return serverIp;
  }

  static String get baseUrl => 'http://$host/food_api';

  static String get loginUrl => '$baseUrl/login.php';
  static String get registerUrl => '$baseUrl/register.php';
  static String get updateProfileUrl => '$baseUrl/update_profile.php';
  static String get getFoodsUrl => '$baseUrl/get_foods.php';
  static String get placeOrderUrl => '$baseUrl/place_order.php';
}
