import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String shortLocationName;
  final bool isLiveGps;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.shortLocationName,
    this.isLiveGps = false,
  });
}

class LocationService {
  /// Fetches the phone's live GPS location with robust permission and signal handling
  static Future<LocationResult> fetchLiveLocation({bool allowMockFallback = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled on the phone
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (allowMockFallback) {
        return _buildFallbackResult('Location services disabled');
      }
      throw Exception('Location service is turned off. Please enable GPS in device settings.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (allowMockFallback) {
          return _buildFallbackResult('Location permission denied');
        }
        throw Exception('Location permission was denied. Please allow location access to detect your live location.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (allowMockFallback) {
        return _buildFallbackResult('Location permission denied forever');
      }
      throw Exception('Location permission is permanently denied. Please enable it in system app settings.');
    }

    Position? position;
    try {
      // First try last known position (fast on mobile)
      position = await Geolocator.getLastKnownPosition();
    } catch (_) {}

    try {
      // Fetch fresh GPS position with 8-second timeout
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      position = fresh;
    } catch (e) {
      debugPrint('Geolocator getCurrentPosition timeout/error: $e');
    }

    if (position == null) {
      if (allowMockFallback) {
        return _buildFallbackResult('GPS signal timeout');
      }
      throw Exception('Unable to acquire GPS signal. Please check your device location settings and try again.');
    }

    // Reverse geocode the live coordinates into human-readable address
    final geocoded = await reverseGeocode(position.latitude, position.longitude);

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      formattedAddress: geocoded.formattedAddress,
      shortLocationName: geocoded.shortLocationName,
      isLiveGps: true,
    );
  }

  /// Converts coordinates into a clean Sri Lankan address using dual-engine reverse geocoding
  static Future<LocationResult> reverseGeocode(double latitude, double longitude) async {
    // 1. First try OpenStreetMap Nominatim for detailed and reliable street addresses
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'BonchiFoodOrderingSystem/1.0 (bonchiapp@foodsystem.lk)',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['address'] != null) {
          final addr = data['address'] as Map<String, dynamic>;
          final houseNumber = addr['house_number'] ?? '';
          final road = addr['road'] ?? addr['pedestrian'] ?? addr['street'] ?? addr['neighbourhood'] ?? '';
          final suburb = addr['suburb'] ?? addr['subdistrict'] ?? addr['residential'] ?? '';
          final city = addr['city'] ?? addr['town'] ?? addr['municipality'] ?? addr['village'] ?? addr['county'] ?? '';

          List<String> parts = [];
          if (houseNumber.isNotEmpty) parts.add('No. $houseNumber');
          if (road.isNotEmpty) parts.add(road);
          if (suburb.isNotEmpty && suburb != road) parts.add(suburb);
          if (city.isNotEmpty && city != suburb) parts.add(city);

          final short = suburb.isNotEmpty
              ? suburb
              : (road.isNotEmpty ? road : (city.isNotEmpty ? city : 'Delivery Location'));
          final formatted = parts.isNotEmpty
              ? parts.join(', ')
              : (data['display_name']?.toString().split(',').take(3).join(',') ?? 'Pinned Location');

          return LocationResult(
            latitude: latitude,
            longitude: longitude,
            formattedAddress: formatted,
            shortLocationName: short,
          );
        }
      }
    } catch (e) {
      debugPrint('OSM Nominatim reverse geocode error: $e');
    }

    // 2. Native Geocoding fallback
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude)
          .timeout(const Duration(seconds: 3));
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = place.name ?? '';
        final street = place.street ?? '';
        final subLocality = place.subLocality ?? place.locality ?? '';
        final city = place.subAdministrativeArea ?? place.administrativeArea ?? '';

        final short = subLocality.isNotEmpty ? subLocality : (city.isNotEmpty ? city : 'Selected Location');
        List<String> parts = [];
        if (name.isNotEmpty && name != street) parts.add(name);
        if (street.isNotEmpty) parts.add(street);
        if (subLocality.isNotEmpty) parts.add(subLocality);
        if (city.isNotEmpty) parts.add(city);

        final formatted = parts.join(', ');
        if (formatted.isNotEmpty) {
          return LocationResult(
            latitude: latitude,
            longitude: longitude,
            formattedAddress: formatted,
            shortLocationName: short,
          );
        }
      }
    } catch (e) {
      debugPrint('Native geocoding error: $e');
    }

    // 3. Coordinate-based fallback
    return LocationResult(
      latitude: latitude,
      longitude: longitude,
      formattedAddress: 'Location (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
      shortLocationName: 'Pinned Location',
    );
  }

  /// Searches for places in Sri Lanka using OpenStreetMap Nominatim
  static Future<List<LocationResult>> searchPlaces(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final encoded = Uri.encodeComponent(query.trim());
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&countrycodes=lk&limit=5&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'BonchiFoodOrderingSystem/1.0 (bonchiapp@foodsystem.lk)',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((item) {
          final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0;
          final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0;
          final displayName = item['display_name']?.toString() ?? query;
          final addr = (item['address'] as Map<String, dynamic>?) ?? {};
          final shortName = addr['suburb'] ?? addr['road'] ?? addr['city'] ?? item['name'] ?? 'Location';
          return LocationResult(
            latitude: lat,
            longitude: lon,
            formattedAddress: displayName,
            shortLocationName: shortName.toString(),
          );
        }).where((res) => res.latitude != 0.0 && res.longitude != 0.0).toList();
      }
    } catch (e) {
      debugPrint('Search places error: $e');
    }
    return [];
  }

  static LocationResult _buildFallbackResult(String reason) {
    debugPrint('Using location fallback: $reason');
    return LocationResult(
      latitude: 6.9085,
      longitude: 79.8512,
      formattedAddress: 'No. 45, Galle Road, Colombo 03',
      shortLocationName: 'Colombo 03',
    );
  }
}
