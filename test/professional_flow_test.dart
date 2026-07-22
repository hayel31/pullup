import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/features/shared/data/demo_pullup_repository.dart';
import 'package:pullup/features/shared/domain/demo_account.dart';
import 'package:pullup/models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('demo profiles and events are all centered on Toulouse', () {
    final snapshot = DemoPullupRepository().snapshot;

    expect(snapshot.users, isNotEmpty);
    expect(snapshot.events, isNotEmpty);
    expect(snapshot.users.every((user) => user.city == 'Toulouse'), isTrue);
    expect(snapshot.events.every((event) => event.city == 'Toulouse'), isTrue);

    final professionalAccounts = demoAccounts
        .where((account) => account.isProfessional)
        .toList();
    expect(professionalAccounts, hasLength(2));
    expect(
      professionalAccounts.map((account) => account.professionalCategory),
      containsAll([ProfessionalCategory.dj, ProfessionalCategory.bar]),
    );
  });

  test(
    'liking an open venue event does not create an approval request',
    () async {
      final repository = DemoPullupRepository();
      const userId = 'host-001';
      const eventId = 'event-008';
      final before = repository.snapshot.events.firstWhere(
        (event) => event.id == eventId,
      );
      final requestCount = repository.snapshot.requests.length;

      expect(before.organizerType, EventOrganizerType.venue);
      expect(before.guestInteractionMode, GuestInteractionMode.openInterest);

      await repository.likeEvent(userId, eventId);

      final after = repository.snapshot.events.firstWhere(
        (event) => event.id == eventId,
      );
      expect(after.likeCount, before.likeCount + 1);
      expect(repository.snapshot.requests, hasLength(requestCount));
      expect(repository.snapshot.swipedEventIds[userId], contains(eventId));
    },
  );

  test(
    'a matching DJ application reserves no guest spot when accepted',
    () async {
      final repository = DemoPullupRepository();
      const eventId = 'event-004';
      final before = repository.snapshot.events.firstWhere(
        (event) => event.id == eventId,
      );

      final request = await repository.applyAsProfessional(
        'dj-001',
        eventId,
        message: 'Nina Volt is available for this set.',
      );

      expect(request.kind, EventRequestKind.professionalService);
      expect(request.professionalCategory, ProfessionalCategory.dj);
      expect(request.reservedSpots, 0);

      final match = await repository.acceptRequest('host-003', request.id);
      final after = repository.snapshot.events.firstWhere(
        (event) => event.id == eventId,
      );
      final accepted = repository.snapshot.requests.firstWhere(
        (candidate) => candidate.id == request.id,
      );

      expect(accepted.status, RequestStatus.accepted);
      expect(after.availableSpots, before.availableSpots);
      expect(match.userId, 'dj-001');
      expect(
        repository.snapshot.conversations.any(
          (conversation) => conversation.id == match.conversationId,
        ),
        isTrue,
      );
    },
  );
}
