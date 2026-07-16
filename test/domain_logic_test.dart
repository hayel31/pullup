import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/core/utils/age_utils.dart';
import 'package:pullup/core/utils/distance_utils.dart';
import 'package:pullup/core/utils/recommendation_engine.dart';
import 'package:pullup/features/shared/data/demo_pullup_repository.dart';
import 'package:pullup/features/shared/domain/app_drafts.dart';
import 'package:pullup/models/discover_filter.dart';
import 'package:pullup/models/enums.dart';
import 'package:pullup/models/geo_point_lite.dart';

void main() {
  test('validates minimum age', () {
    expect(
      AgeUtils.isMinimumAge(DateTime(2008, 7, 15), now: DateTime(2026, 7, 16)),
      isTrue,
    );
    expect(
      AgeUtils.isMinimumAge(DateTime(2009, 7, 17), now: DateTime(2026, 7, 16)),
      isFalse,
    );
  });

  test('calculates distance between nearby points', () {
    final distance = DistanceUtils.kilometersBetween(
      const GeoPointLite(latitude: 48.8566, longitude: 2.3522),
      const GeoPointLite(latitude: 48.8584, longitude: 2.2945),
    );
    expect(distance, greaterThan(3));
    expect(distance, lessThan(6));
  });

  test('recommendation engine filters own, expired and swiped events', () {
    final repository = DemoPullupRepository();
    final user = repository.snapshot.users.firstWhere(
      (user) => user.id == 'user-001',
    );
    final ranked = RecommendationEngine.rank(
      user: user,
      events: repository.snapshot.events,
      filter: DiscoverFilter.defaults,
      swipedEventIds: {'event-001'},
      rejectedEventIds: const {},
      now: DateTime.now(),
    );
    expect(ranked.map((item) => item.event.id), isNot(contains('event-001')));
    expect(ranked.any((item) => item.event.hostId == user.id), isFalse);
  });

  test(
    'accepting a request creates match, conversation and decrements spots',
    () async {
      final repository = DemoPullupRepository();
      final request = await repository.requestToJoin(
        'user-002',
        'event-002',
        const JoinEventDraft(
          note: 'Group of two, respectful energy.',
          groupSize: 2,
          companionNames: ['Tom'],
        ),
      );
      final before = repository.snapshot.events
          .firstWhere((event) => event.id == 'event-002')
          .availableSpots;
      final match = await repository.acceptRequest('host-002', request.id);
      final after = repository.snapshot.events
          .firstWhere((event) => event.id == 'event-002')
          .availableSpots;

      expect(match.conversationId, startsWith('conversation-'));
      expect(after, before - 2);
      expect(
        repository.snapshot.conversations.any(
          (conversation) => conversation.id == match.conversationId,
        ),
        isTrue,
      );
    },
  );

  test(
    'rejecting a request keeps spots unchanged and prevents aggressive copy',
    () async {
      final repository = DemoPullupRepository();
      final request = await repository.requestToJoin(
        'user-004',
        'event-002',
        const JoinEventDraft(
          note: 'I can bring snacks.',
          groupSize: 1,
          companionNames: [],
        ),
      );
      final before = repository.snapshot.events
          .firstWhere((event) => event.id == 'event-002')
          .availableSpots;
      final rejected = await repository.rejectRequest('host-002', request.id);
      final after = repository.snapshot.events
          .firstWhere((event) => event.id == 'event-002')
          .availableSpots;

      expect(rejected.status, RequestStatus.rejected);
      expect(after, before);
      expect(
        repository.snapshot.notifications.last.body,
        contains('did not work out'),
      );
    },
  );
}
