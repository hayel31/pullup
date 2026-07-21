import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../domain/address_suggestion.dart';

final addressSearchServiceProvider = Provider<AddressSearchService>((ref) {
  final service = IgnAddressSearchService();
  ref.onDispose(service.close);
  return service;
});

abstract interface class AddressSearchService {
  Future<List<AddressSuggestion>> search(
    String query, {
    String? cityHint,
    int limit = 5,
  });
}

class AddressSearchException implements Exception {
  const AddressSearchException();
}

class IgnAddressSearchService implements AddressSearchService {
  IgnAddressSearchService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<List<AddressSuggestion>> search(
    String query, {
    String? cityHint,
    int limit = 5,
  }) async {
    final normalized = query.trim();
    if (normalized.length < 3) return const [];
    final scopedQuery = cityHint?.trim().isNotEmpty ?? false
        ? '$normalized ${cityHint!.trim()}'
        : normalized;
    final uri = Uri.https('data.geopf.fr', '/geocodage/completion/', {
      'text': scopedQuery,
      'type': 'StreetAddress',
      'maximumResponses': limit.clamp(1, 10).toString(),
    });

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 7));
      if (response.statusCode != 200) {
        throw const AddressSearchException();
      }
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is! Map) return const [];
      final rawResults = payload['results'];
      if (rawResults is! List) return const [];
      final suggestions = <AddressSuggestion>[];
      for (final item in rawResults) {
        if (item is! Map) continue;
        try {
          suggestions.add(
            AddressSuggestion.fromJson(Map<String, dynamic>.from(item)),
          );
        } on FormatException {
          continue;
        }
      }
      return suggestions;
    } on AddressSearchException {
      rethrow;
    } catch (_) {
      throw const AddressSearchException();
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
