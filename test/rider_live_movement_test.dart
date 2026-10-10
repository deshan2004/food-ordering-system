import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

double calculateDistanceMeters(LatLng p1, LatLng p2) {
  const double earthRadius = 6371000;
  final double dLat = (p2.latitude - p1.latitude) * (math.pi / 180.0);
  final double dLng = (p2.longitude - p1.longitude) * (math.pi / 180.0);
  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(p1.latitude * (math.pi / 180.0)) *
          math.cos(p2.latitude * (math.pi / 180.0)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double calculateBearing(LatLng start, LatLng end) {
  final double lat1 = start.latitude * (math.pi / 180.0);
  final double lon1 = start.longitude * (math.pi / 180.0);
  final double lat2 = end.latitude * (math.pi / 180.0);
  final double lon2 = end.longitude * (math.pi / 180.0);
  final double dLon = lon2 - lon1;

  final double y = math.sin(dLon) * math.cos(lat2);
  final double x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  final double radians = math.atan2(y, x);
  return (radians * (180.0 / math.pi) + 360.0) % 360.0;
}

void main() {
  group('Rider Live Movement & Route Interpolation Tests', () {
    const pPilawos = LatLng(6.9085, 79.8512);
    const pGalleRd = LatLng(6.9073, 79.8517);
    const pDest = LatLng(6.9015, 79.8560);

    test('calculateDistanceMeters computes reasonable Colombo street distance', () {
      final dist = calculateDistanceMeters(pPilawos, pGalleRd);
      expect(dist, greaterThan(100.0));
      expect(dist, lessThan(300.0));
    });

    test('calculateBearing produces valid heading angle in [0, 360)', () {
      final bearing = calculateBearing(pPilawos, pDest);
      expect(bearing, greaterThanOrEqualTo(0.0));
      expect(bearing, lessThan(360.0));
    });

    test('Multi-waypoint interpolation accumulates distance and estimates ETA', () {
      final waypoints = [pPilawos, pGalleRd, pDest];
      double totalDistance = 0.0;
      for (int i = 0; i < waypoints.length - 1; i++) {
        totalDistance += calculateDistanceMeters(waypoints[i], waypoints[i + 1]);
      }

      final totalKm = totalDistance / 1000.0;
      expect(totalKm, greaterThan(0.5));
      expect(totalKm, lessThan(3.0));

      final etaMins = (totalKm * 3.2 + 1).ceil();
      expect(etaMins, greaterThan(1));
      expect(etaMins, lessThan(15));
    });
  });
}
