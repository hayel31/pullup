import 'dart:math';

import '../../models/geo_point_lite.dart';

class DistanceUtils {
  const DistanceUtils._();

  static double kilometersBetween(GeoPointLite a, GeoPointLite b) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLng = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);
    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * earthRadiusKm * atan2(sqrt(h), sqrt(1 - h));
  }

  static GeoPointLite blur(GeoPointLite point, {double precision = 0.015}) {
    final lat = (point.latitude / precision).round() * precision;
    final lng = (point.longitude / precision).round() * precision;
    return GeoPointLite(latitude: lat, longitude: lng);
  }

  static double _degToRad(double degree) => degree * pi / 180;
}
