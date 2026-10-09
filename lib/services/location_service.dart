import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String shortLocationName;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.shortLocationName,
  });
}

class LocationService {
  /// Fetches the phone's live GPS location with robust fallback handling
  static Future<LocationResult> fetchLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled on the phone
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _buildFallbackResult('Location services disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _buildFallbackResult('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return _buildFallbackResult('Location permission denied forever');
    }

    Position? position;
    try {
      // First try last known position (fastest for simulators / devices)
      position = await Geolocator.getLastKnownPosition();
    } catch (_) {}

    if (position == null) {
      try {
        // High-speed fallback to current position with 4 second limit
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );
      } catch (e) {
        debugPrint('Geolocator current position timeout/error: $e');
      }
    }

    if (position == null) {
      return _buildFallbackResult('Galle Road, Colombo 03');
    }

    // Convert GPS coordinates into human-readable street address
    String formattedAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    String shortName = 'Current Location';

    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 3));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = place.name ?? '';
        final street = place.street ?? '';
        final subLocality = place.subLocality ?? place.locality ?? '';
        final city = place.subAdministrativeArea ?? place.administrativeArea ?? '';

        shortName = subLocality.isNotEmpty ? subLocality : (city.isNotEmpty ? city : 'My Location');
        
        List<String> parts = [];
        if (name.isNotEmpty && name != street) parts.add(name);
        if (street.isNotEmpty) parts.add(street);
        if (subLocality.isNotEmpty) parts.add(subLocality);
        if (city.isNotEmpty) parts.add(city);

        formattedAddress = parts.join(', ');
      }
    } catch (e) {
      debugPrint('Reverse geocoding timeout/error: $e');
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      formattedAddress: formattedAddress.isNotEmpty ? formattedAddress : 'No 45, Galle Road, Colombo 03',
      shortLocationName: shortName.isNotEmpty ? shortName : 'Colombo 03',
    );
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
