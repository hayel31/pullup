import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/features/shared/data/demo_pullup_repository.dart';
import 'package:pullup/features/shared/domain/app_drafts.dart';
import 'package:pullup/features/shared/domain/demo_account.dart';
import 'package:pullup/models/enums.dart';
import 'package:pullup/models/geo_point_lite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('the four demo hosts can sign in and own published events', () async {
    final repository = DemoPullupRepository();

    for (final account in demoAccounts) {
      final user = await repository.signIn(
        email: account.email,
        password: account.password,
      );
      expect(user.id, account.userId);
      expect(
        repository.snapshot.events.any((event) => event.hostId == user.id),
        isTrue,
      );
    }
  });

  test(
    'a registered account, session and created event survive reload',
    () async {
      final firstRepository = DemoPullupRepository();
      final user = await firstRepository.register(
        SignUpDraft(
          firstName: 'Ava',
          displayName: 'Ava Nights',
          birthDate: DateTime(1998, 5, 12),
          gender: Gender.woman,
          city: 'Paris',
          email: 'ava@example.com',
          password: 'SecureDemo42!',
          acceptedTerms: true,
          confirmedMinimumAge: true,
        ),
      );
      final now = DateTime.now();
      const selectedPhoto =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScL4WQAAAABJRU5ErkJggg==';
      final event = await firstRepository.createEvent(
        user.id,
        CreateEventDraft(
          title: 'Ava rooftop',
          description: 'A private rooftop night with house music.',
          category: EventCategory.rooftop,
          coverPhotoUrl: selectedPhoto,
          photoUrls: const [selectedPhoto],
          city: 'Toulouse',
          areaName: 'Saint-Cyprien',
          approximateGeoPoint: const GeoPointLite(
            latitude: 43.6047,
            longitude: 1.4442,
          ),
          exactAddress: '10 Rue de Test, 31000 Toulouse',
          startDateTime: now.add(const Duration(hours: 2)),
          endDateTime: now.add(const Duration(hours: 7)),
          timezone: 'Europe/Paris',
          ageRequirement: 18,
          maxParticipants: 12,
          allowsGroups: true,
          maxGroupSize: 4,
          eventTags: const [EventTag.outdoor, EventTag.dj],
          musicGenres: const ['House'],
          alcoholPolicy: AlcoholPolicy.allowed,
          smokingPolicy: SmokingPolicy.noSmoking,
          visibility: EventVisibility.public,
          approvalMode: ApprovalMode.manual,
        ),
      );

      final restoredRepository = DemoPullupRepository();
      final restoredUser = await restoredRepository.restoreSession();

      expect(restoredUser?.id, user.id);
      final restoredEvent = restoredRepository.snapshot.events.firstWhere(
        (item) => item.id == event.id,
      );
      expect(restoredEvent.coverPhotoUrl, selectedPhoto);
      expect(restoredEvent.photoUrls, const [selectedPhoto]);
      expect(restoredEvent.city, 'Toulouse');
      expect(restoredEvent.areaName, 'Saint-Cyprien');
      expect(
        restoredEvent.approximateGeoPoint.latitude,
        closeTo(43.6047, 0.0001),
      );
      expect(
        restoredEvent.approximateGeoPoint.longitude,
        closeTo(1.4442, 0.0001),
      );
      final signedInAgain = await restoredRepository.signIn(
        email: 'ava@example.com',
        password: 'SecureDemo42!',
      );
      expect(signedInAgain.id, user.id);
    },
  );
}
