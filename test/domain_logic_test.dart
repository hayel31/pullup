import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/core/errors/app_exception.dart';
import 'package:pullup/core/utils/age_utils.dart';
import 'package:pullup/core/utils/distance_utils.dart';
import 'package:pullup/core/utils/recommendation_engine.dart';
import 'package:pullup/features/shared/data/demo_pullup_repository.dart';
import 'package:pullup/features/shared/domain/app_drafts.dart';
import 'package:pullup/features/shared/domain/demo_account.dart';
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

  test('every demo host has at least one nearby discover recommendation', () {
    final repository = DemoPullupRepository();

    for (final account in demoAccounts) {
      final user = repository.snapshot.users.firstWhere(
        (candidate) => candidate.id == account.userId,
      );
      final ranked = RecommendationEngine.rank(
        user: user,
        events: repository.snapshot.events,
        filter: DiscoverFilter.defaults,
        swipedEventIds: const {},
        rejectedEventIds: const {},
      );

      expect(
        ranked,
        isNotEmpty,
        reason:
            '${account.displayName} should not open an empty Discover feed.',
      );
      expect(ranked.every((item) => item.event.hostId != user.id), isTrue);
    }
  });

  test('demo events use stable category-specific local imagery', () {
    final events = DemoPullupRepository().snapshot.events;
    final covers = events.map((event) => event.coverPhotoUrl).toList();

    expect(events, hasLength(10));
    expect(covers.toSet(), hasLength(8));
    expect(covers, everyElement(startsWith('assets/demo/events/')));
    expect(covers, isNot(anyElement(contains('picsum.photos'))));
    for (final event in events) {
      expect(event.photoUrls, contains(event.coverPhotoUrl));
    }
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

  test(
    'withdrawing a pending request clears the waitlist and allows resubmission',
    () async {
      final repository = DemoPullupRepository();
      final request = await repository.requestToJoin(
        'user-004',
        'event-002',
        const JoinEventDraft(
          note: 'I may need to change plans.',
          groupSize: 1,
          companionNames: [],
        ),
      );
      final before = repository.snapshot.events.firstWhere(
        (event) => event.id == request.eventId,
      );

      final withdrawn = await repository.withdrawRequest(
        'user-004',
        request.id,
      );
      final after = repository.snapshot.events.firstWhere(
        (event) => event.id == request.eventId,
      );

      expect(withdrawn.status, RequestStatus.withdrawn);
      expect(after.waitingParticipantIds, isNot(contains('user-004')));
      expect(after.requestCount, before.requestCount - 1);
      expect(
        repository.snapshot.swipedEventIds['user-004'],
        isNot(contains(request.eventId)),
      );

      final resubmitted = await repository.requestToJoin(
        'user-004',
        request.eventId,
        const JoinEventDraft(
          note: 'Plans confirmed now.',
          groupSize: 1,
          companionNames: [],
        ),
      );
      expect(resubmitted.status, RequestStatus.pending);
    },
  );

  test('an accepted request cannot be withdrawn', () async {
    final repository = DemoPullupRepository();
    final request = await repository.requestToJoin(
      'user-004',
      'event-002',
      const JoinEventDraft(
        note: 'Ready to join.',
        groupSize: 1,
        companionNames: [],
      ),
    );
    await repository.acceptRequest('host-002', request.id);

    expect(
      repository.withdrawRequest('user-004', request.id),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Only pending requests can be withdrawn.',
        ),
      ),
    );
  });

  test('friend connections are reciprocal and can be removed', () async {
    final repository = DemoPullupRepository();

    await repository.removeFriend('user-001', 'user-002');
    expect(
      repository.snapshot.users
          .firstWhere((user) => user.id == 'user-001')
          .friendIds,
      isNot(contains('user-002')),
    );
    expect(
      repository.snapshot.users
          .firstWhere((user) => user.id == 'user-002')
          .friendIds,
      isNot(contains('user-001')),
    );

    await repository.addFriend('user-001', 'user-002');
    expect(
      repository.snapshot.users
          .firstWhere((user) => user.id == 'user-001')
          .friendIds,
      contains('user-002'),
    );
    expect(
      repository.snapshot.users
          .firstWhere((user) => user.id == 'user-002')
          .friendIds,
      contains('user-001'),
    );
  });

  test(
    'accepting a mixed group opens an identified 12-hour group chat',
    () async {
      final repository = DemoPullupRepository();
      final request = await repository.requestToJoin(
        'user-001',
        'event-002',
        const JoinEventDraft(
          note: 'Enzo joins me with two guests.',
          groupSize: 4,
          companionUserIds: ['user-002'],
          guestMenCount: 1,
          guestWomenCount: 1,
        ),
      );

      expect(request.companionUserIds, ['user-002']);
      expect(request.guestMenCount, 1);
      expect(request.guestWomenCount, 1);

      final acceptedAt = DateTime.now();
      final match = await repository.acceptRequest('host-002', request.id);
      final conversation = repository.snapshot.conversations.firstWhere(
        (item) => item.id == match.conversationId,
      );

      expect(conversation.isGroup, isTrue);
      expect(conversation.memberIds.toSet(), {
        'host-002',
        'user-001',
        'user-002',
      });
      expect(conversation.expiresAt, isNotNull);
      expect(
        conversation.expiresAt!.difference(acceptedAt).inMinutes,
        inInclusiveRange(719, 720),
      );
    },
  );

  test('a request cannot add someone who is not a confirmed friend', () {
    final repository = DemoPullupRepository();
    expect(
      repository.requestToJoin(
        'user-001',
        'event-002',
        const JoinEventDraft(
          note: 'Invalid group.',
          groupSize: 2,
          companionUserIds: ['user-005'],
        ),
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Only confirmed PULLUP friends can join your group.',
        ),
      ),
    );
  });
}
