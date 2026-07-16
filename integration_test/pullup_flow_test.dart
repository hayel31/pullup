import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pullup/app/providers/app_state.dart';
import 'package:pullup/features/shared/domain/app_drafts.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo account can request and host can accept into chat', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(appControllerProvider.notifier);

    await controller.signInDemo();
    await controller.requestToJoin(
      'event-002',
      const JoinEventDraft(
        note: 'I can bring drinks.',
        groupSize: 1,
        companionNames: [],
      ),
    );

    final guestState = container.read(appControllerProvider);
    final request = guestState.requests.firstWhere(
      (item) =>
          item.eventId == 'event-002' &&
          item.requesterId == guestState.currentUser!.id,
    );

    await controller.signOut();
    await controller.signInDemo(asHost: true);
    await controller.acceptRequest(request.id);

    final hostState = container.read(appControllerProvider);
    expect(
      hostState.matches.any((match) => match.eventId == 'event-002'),
      isTrue,
    );
    expect(
      hostState.conversations.any((chat) => chat.eventId == 'event-002'),
      isTrue,
    );
  });
}
