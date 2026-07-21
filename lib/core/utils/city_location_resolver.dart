import '../../models/geo_point_lite.dart';

class CityLocationResolver {
  const CityLocationResolver._();

  static const _locations = <String, GeoPointLite>{
    'paris': GeoPointLite(latitude: 48.8566, longitude: 2.3522),
    'toulouse': GeoPointLite(latitude: 43.6047, longitude: 1.4442),
    'lyon': GeoPointLite(latitude: 45.7640, longitude: 4.8357),
    'marseille': GeoPointLite(latitude: 43.2965, longitude: 5.3698),
    'nice': GeoPointLite(latitude: 43.7102, longitude: 7.2620),
    'cannes': GeoPointLite(latitude: 43.5528, longitude: 7.0174),
    'bordeaux': GeoPointLite(latitude: 44.8378, longitude: -0.5792),
    'lille': GeoPointLite(latitude: 50.6292, longitude: 3.0573),
    'montpellier': GeoPointLite(latitude: 43.6108, longitude: 3.8767),
    'nantes': GeoPointLite(latitude: 47.2184, longitude: -1.5536),
    'strasbourg': GeoPointLite(latitude: 48.5734, longitude: 7.7521),
    'rennes': GeoPointLite(latitude: 48.1173, longitude: -1.6778),
    'barcelona': GeoPointLite(latitude: 41.3874, longitude: 2.1686),
    'barcelone': GeoPointLite(latitude: 41.3874, longitude: 2.1686),
    'madrid': GeoPointLite(latitude: 40.4168, longitude: -3.7038),
    'berlin': GeoPointLite(latitude: 52.5200, longitude: 13.4050),
    'london': GeoPointLite(latitude: 51.5072, longitude: -0.1276),
    'londres': GeoPointLite(latitude: 51.5072, longitude: -0.1276),
  };

  static GeoPointLite resolve(String city, {required GeoPointLite fallback}) {
    return _locations[_normalize(city)] ?? fallback;
  }

  static bool supports(String city) => _locations.containsKey(_normalize(city));

  static String timezoneFor(String city) {
    return switch (_normalize(city)) {
      'barcelona' || 'barcelone' || 'madrid' => 'Europe/Madrid',
      'berlin' => 'Europe/Berlin',
      'london' || 'londres' => 'Europe/London',
      _ => 'Europe/Paris',
    };
  }

  static String _normalize(String value) {
    final normalized = value.trim().toLowerCase().codeUnits.map((codeUnit) {
      return switch (codeUnit) {
        0xE0 || 0xE1 || 0xE2 || 0xE3 || 0xE4 || 0xE5 => 0x61,
        0xE7 => 0x63,
        0xE8 || 0xE9 || 0xEA || 0xEB => 0x65,
        0xEC || 0xED || 0xEE || 0xEF => 0x69,
        0xF1 => 0x6E,
        0xF2 || 0xF3 || 0xF4 || 0xF5 || 0xF6 => 0x6F,
        0xF9 || 0xFA || 0xFB || 0xFC => 0x75,
        0xFD || 0xFF => 0x79,
        _ => codeUnit,
      };
    });
    return String.fromCharCodes(normalized);
  }
}
