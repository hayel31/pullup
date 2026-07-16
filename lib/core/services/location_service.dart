import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

import '../../models/geo_point_lite.dart';
import '../errors/app_exception.dart';
import '../utils/distance_utils.dart';

class LocationService {
  const LocationService();

  Future<GeoPointLite> currentApproximateLocation() async {
    final locationPermission = await permissions.Permission.locationWhenInUse
        .request();
    if (!locationPermission.isGranted) {
      throw const AppException(
        'Location permission denied.',
        code: 'permission-denied',
      );
    }
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const AppException(
        'Location services are disabled.',
        code: 'location-disabled',
      );
    }
    final position = await Geolocator.getCurrentPosition();
    return DistanceUtils.blur(
      GeoPointLite(latitude: position.latitude, longitude: position.longitude),
    );
  }
}
