import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  /// Local network IP address of your Mac hosting the XAMPP MySQL/PHP server
  /// (On iOS Simulator & macOS, 127.0.0.1 connects directly to the host Mac)
  static const String currentMacWifiIp = '172.20.10.3';
  static const String legacyWifiIp = '192.168.1.5';

  static String get defaultHost {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        // iOS Simulator & macOS communicate with local XAMPP Apache on localhost / 127.0.0.1
        return '127.0.0.1';
      }
      if (Platform.isAndroid) {
        return '10.0.2.2';
      }
    } catch (_) {}
    return currentMacWifiIp;
  }

  static String _activeHost = defaultHost;
  static String get host => _activeHost;

  static String get baseUrl => 'http://$_activeHost/food_api';
  static String get loginUrl => '$baseUrl/login.php';
  static String get registerUrl => '$baseUrl/register.php';
  static String get updateProfileUrl => '$baseUrl/update_profile.php';
  static String get getFoodsUrl => '$baseUrl/get_foods.php';
  static String get placeOrderUrl => '$baseUrl/place_order.php';

  static List<String> get candidateHosts {
    if (kIsWeb) return ['localhost'];
    return {
      _activeHost,
      '127.0.0.1',
      'localhost',
      currentMacWifiIp,
      '10.0.2.2',
      legacyWifiIp,
    }.toList();
  }

  /// Sends a POST request trying candidate hosts if connection fails
  static Future<http.Response> postMultiHost(
    String endpoint, {
    required Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final hosts = candidateHosts;
    dynamic lastError;

    for (final h in hosts) {
      final url = 'http://$h/food_api/$endpoint';
      try {
        final res = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(timeout);

        // Found working host!
        _activeHost = h;
        return res;
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('Could not connect to any food_api host');
  }

  /// Sends a GET request trying candidate hosts
  static Future<http.Response> getMultiHost(
    String endpoint, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final hosts = candidateHosts;
    dynamic lastError;

    for (final h in hosts) {
      final url = 'http://$h/food_api/$endpoint';
      try {
        final res = await http.get(Uri.parse(url)).timeout(timeout);
        _activeHost = h;
        return res;
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('Could not connect to any food_api host');
  }
}
