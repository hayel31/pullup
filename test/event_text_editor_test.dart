import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/app/theme/app_theme.dart';
import 'package:pullup/features/events/data/address_search_service.dart';
import 'package:pullup/features/events/domain/address_suggestion.dart';
import 'package:pullup/features/events/presentation/widgets/event_text_editor.dart';
import 'package:pullup/models/geo_point_lite.dart';

void main() {
  testWidgets('keeps the active event field above a mobile keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            viewInsets: EdgeInsets.only(bottom: 360),
          ),
          child: EventTextEditor(label: 'Event title', initialValue: ''),
        ),
      ),
    );
    await tester.pump();

    final inputRect = tester.getRect(
      find.byKey(const Key('event-editor-input')),
    );
    expect(inputRect.top, lessThan(180));
    expect(inputRect.bottom, lessThan(844 - 360));
    expect(find.byKey(const Key('event-editor-done')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('event-editor-input')),
      'Toulouse rooftop',
    );
    expect(find.text('Toulouse rooftop'), findsOneWidget);
  });

  testWidgets('shows smart address suggestions after a short debounce', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: EventTextEditor(
          label: 'Private address',
          initialValue: '',
          addressSearchService: _FakeAddressSearchService(),
          cityHint: 'Toulouse',
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Start typing a street address to see verified suggestions.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('event-editor-input')),
      '10 rue',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('10 Rue Alsace Lorraine, 31000 Toulouse'), findsOneWidget);
  });
}

class _FakeAddressSearchService implements AddressSearchService {
  @override
  Future<List<AddressSuggestion>> search(
    String query, {
    String? cityHint,
    int limit = 5,
  }) async {
    return const [
      AddressSuggestion(
        label: '10 Rue Alsace Lorraine, 31000 Toulouse',
        city: 'Toulouse',
        postalCode: '31000',
        location: GeoPointLite(latitude: 43.606, longitude: 1.447),
      ),
    ];
  }
}
