import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/core/utils/city_location_resolver.dart';
import 'package:pullup/models/geo_point_lite.dart';

void main() {
  test('resolves Toulouse instead of falling back to Paris', () {
    final location = CityLocationResolver.resolve(
      ' Toulouse ',
      fallback: const GeoPointLite(latitude: 48.8566, longitude: 2.3522),
    );

    expect(location.latitude, closeTo(43.6047, 0.0001));
    expect(location.longitude, closeTo(1.4442, 0.0001));
    expect(CityLocationResolver.timezoneFor('Toulouse'), 'Europe/Paris');
  });

  test('normalizes accented city names', () {
    final location = CityLocationResolver.resolve(
      'Barcelone',
      fallback: const GeoPointLite(latitude: 0, longitude: 0),
    );

    expect(location.latitude, closeTo(41.3874, 0.0001));
    expect(CityLocationResolver.timezoneFor('Barcelone'), 'Europe/Madrid');
  });
}
