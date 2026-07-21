import '../../../models/geo_point_lite.dart';

class AddressSuggestion {
  const AddressSuggestion({
    required this.label,
    required this.city,
    required this.postalCode,
    required this.location,
  });

  final String label;
  final String city;
  final String postalCode;
  final GeoPointLite location;

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final coordinates = geometry is Map ? geometry['coordinates'] : null;
    final longitude =
        _number(json['x']) ??
        (coordinates is List && coordinates.isNotEmpty
            ? _number(coordinates.first)
            : null);
    final latitude =
        _number(json['y']) ??
        (coordinates is List && coordinates.length > 1
            ? _number(coordinates[1])
            : null);
    final label =
        _text(json['fulltext']) ?? _text(json['label']) ?? _text(json['name']);
    if (label == null || latitude == null || longitude == null) {
      throw const FormatException('Incomplete address suggestion');
    }
    return AddressSuggestion(
      label: label,
      city: _text(json['city']) ?? '',
      postalCode: _text(json['zipcode']) ?? _text(json['postcode']) ?? '',
      location: GeoPointLite(latitude: latitude, longitude: longitude),
    );
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static double? _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
