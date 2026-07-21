import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pullup/features/events/data/address_search_service.dart';

void main() {
  test('IGN autocomplete scopes the query and parses coordinates', () async {
    late Uri requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'results': [
              {
                'fulltext': '14 Rue Keller 75011 Paris',
                'city': 'Paris',
                'zipcode': '75011',
                'x': 2.379,
                'y': 48.854,
              },
            ],
          }),
        ),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = IgnAddressSearchService(client: client);

    final results = await service.search(
      '14 rue Keller',
      cityHint: 'Paris',
      limit: 7,
    );

    expect(requestedUri.host, 'data.geopf.fr');
    expect(requestedUri.path, '/geocodage/completion/');
    expect(requestedUri.queryParameters['text'], '14 rue Keller Paris');
    expect(requestedUri.queryParameters['type'], 'StreetAddress');
    expect(requestedUri.queryParameters['maximumResponses'], '7');
    expect(results.single.label, '14 Rue Keller 75011 Paris');
    expect(results.single.city, 'Paris');
    expect(results.single.location.latitude, closeTo(48.854, 0.0001));
    expect(results.single.location.longitude, closeTo(2.379, 0.0001));
  });

  test('IGN autocomplete converts service failures to a domain error', () {
    final client = MockClient((_) async => http.Response('Unavailable', 503));
    final service = IgnAddressSearchService(client: client);

    expect(
      service.search('10 rue de Rivoli'),
      throwsA(isA<AddressSearchException>()),
    );
  });
}
