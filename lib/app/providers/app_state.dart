import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/recommendation_engine.dart';
import '../../models/chat.dart';
import '../../models/discover_filter.dart';
import '../../models/dj.dart';
import '../../models/enums.dart';
import '../../models/event_request.dart';
import '../../models/notification_item.dart';
import '../../models/party_event.dart';
import '../../models/pullup_match.dart';
import '../../models/report.dart';
import '../../models/user_profile.dart';
import '../../features/shared/data/demo_pullup_repository.dart';
import '../../features/shared/data/firebase_pullup_repository.dart';
import '../../features/shared/domain/app_drafts.dart';
import '../../features/shared/domain/pullup_repository.dart';

final pullupRepositoryProvider = Provider<PullupRepository>((ref) {
  const useFirebase = String.fromEnvironment('USE_FIREBASE') == 'true';
  if (useFirebase) {
    return const FirebasePullupRepository();
  }
  return DemoPullupRepository();
});

final appControllerProvider = StateNotifierProvider<AppController, PullupState>(
  (ref) {
    return AppController(ref.watch(pullupRepositoryProvider));
  },
);

final recommendedEventsProvider = Provider<List<RecommendationScore>>((ref) {
  final state = ref.watch(appControllerProvider);
  final user = state.currentUser;
  if (user == null) return const [];
  return RecommendationEngine.rank(
    user: user,
    events: state.events,
    filter: state.filter,
    swipedEventIds: state.swipedEventIds[user.id] ?? const {},
    rejectedEventIds: state.rejectedEventIds[user.id] ?? const {},
  );
});

final tonightEventsProvider = Provider<List<PartyEvent>>((ref) {
  final state = ref.watch(appControllerProvider);
  final user = state.currentUser;
  if (user == null) return const [];
  final swiped = state.swipedEventIds[user.id] ?? const {};
  return state.events
      .where(
        (event) =>
            event.hostId != user.id &&
            !swiped.contains(event.id) &&
            event.isTonight &&
            event.endDateTime.isAfter(DateTime.now()) &&
            event.status != EventStatus.cancelled &&
            event.status != EventStatus.ended &&
            (event.hasSpots || event.approvalMode == ApprovalMode.manual),
      )
      .toList()
    ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
});

final hostRequestsProvider = Provider<List<EventRequest>>((ref) {
  final state = ref.watch(appControllerProvider);
  final user = state.currentUser;
  if (user == null) return const [];
  return state.requests
      .where(
        (request) =>
            request.hostId == user.id &&
            request.status == RequestStatus.pending,
      )
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final myRequestsProvider = Provider<List<EventRequest>>((ref) {
  final state = ref.watch(appControllerProvider);
  final user = state.currentUser;
  if (user == null) return const [];
  return state.requests
      .where(
        (request) =>
            request.requesterId == user.id &&
            request.status != RequestStatus.withdrawn,
      )
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final myMatchesProvider = Provider<List<PullupMatch>>((ref) {
  final state = ref.watch(appControllerProvider);
  final user = state.currentUser;
  if (user == null) return const [];
  return state.matches
      .where((match) => match.userId == user.id || match.hostId == user.id)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final myConversationsProvider = Provider<List<ChatConversation>>((ref) {
  final state = ref.watch(appControllerProvider);
  final user = state.currentUser;
  if (user == null) return const [];
  return state.conversations
      .where(
        (conversation) =>
            conversation.memberIds.contains(user.id) && !conversation.isExpired,
      )
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
});

final myNotificationsProvider = Provider<List<NotificationItem>>((ref) {
  final state = ref.watch(appControllerProvider);
  final user = state.currentUser;
  if (user == null) return const [];
  return state.notifications
      .where((notification) => notification.userId == user.id)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

enum AppExperience { guest, host }

class PullupState {
  const PullupState({
    required this.loading,
    required this.errorMessage,
    required this.currentUser,
    required this.users,
    required this.events,
    required this.requests,
    required this.matches,
    required this.conversations,
    required this.messages,
    required this.notifications,
    required this.reports,
    required this.djProfiles,
    required this.swipedEventIds,
    required this.rejectedEventIds,
    required this.filter,
    required this.activeExperience,
    this.lastSwipedEventId,
  });

  factory PullupState.fromSnapshot(PullupSnapshot snapshot) {
    return PullupState(
      loading: false,
      errorMessage: null,
      currentUser: null,
      users: snapshot.users,
      events: snapshot.events,
      requests: snapshot.requests,
      matches: snapshot.matches,
      conversations: snapshot.conversations,
      messages: snapshot.messages,
      notifications: snapshot.notifications,
      reports: snapshot.reports,
      djProfiles: snapshot.djProfiles,
      swipedEventIds: snapshot.swipedEventIds,
      rejectedEventIds: snapshot.rejectedEventIds,
      filter: DiscoverFilter.defaults,
      activeExperience: AppExperience.guest,
    );
  }

  final bool loading;
  final String? errorMessage;
  final UserProfile? currentUser;
  final List<UserProfile> users;
  final List<PartyEvent> events;
  final List<EventRequest> requests;
  final List<PullupMatch> matches;
  final List<ChatConversation> conversations;
  final List<ChatMessage> messages;
  final List<NotificationItem> notifications;
  final List<Report> reports;
  final List<DjProfile> djProfiles;
  final Map<String, Set<String>> swipedEventIds;
  final Map<String, Set<String>> rejectedEventIds;
  final DiscoverFilter filter;
  final AppExperience activeExperience;
  final String? lastSwipedEventId;

  bool get isAuthenticated => currentUser != null;
  bool get needsOnboarding =>
      currentUser != null && !currentUser!.onboardingCompleted;

  PullupState copyWith({
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    UserProfile? currentUser,
    bool clearCurrentUser = false,
    List<UserProfile>? users,
    List<PartyEvent>? events,
    List<EventRequest>? requests,
    List<PullupMatch>? matches,
    List<ChatConversation>? conversations,
    List<ChatMessage>? messages,
    List<NotificationItem>? notifications,
    List<Report>? reports,
    List<DjProfile>? djProfiles,
    Map<String, Set<String>>? swipedEventIds,
    Map<String, Set<String>>? rejectedEventIds,
    DiscoverFilter? filter,
    AppExperience? activeExperience,
    String? lastSwipedEventId,
    bool clearLastSwiped = false,
  }) {
    return PullupState(
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentUser: clearCurrentUser ? null : currentUser ?? this.currentUser,
      users: users ?? this.users,
      events: events ?? this.events,
      requests: requests ?? this.requests,
      matches: matches ?? this.matches,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      notifications: notifications ?? this.notifications,
      reports: reports ?? this.reports,
      djProfiles: djProfiles ?? this.djProfiles,
      swipedEventIds: swipedEventIds ?? this.swipedEventIds,
      rejectedEventIds: rejectedEventIds ?? this.rejectedEventIds,
      filter: filter ?? this.filter,
      activeExperience: activeExperience ?? this.activeExperience,
      lastSwipedEventId: clearLastSwiped
          ? null
          : lastSwipedEventId ?? this.lastSwipedEventId,
    );
  }
}

class AppController extends StateNotifier<PullupState> {
  AppController(this._repository)
    : super(PullupState.fromSnapshot(_repository.snapshot)) {
    ready = _restoreSession();
  }

  final PullupRepository _repository;
  late final Future<void> ready;

  Future<void> signIn({required String email, required String password}) async {
    await _run(() async {
      final user = await _repository.signIn(email: email, password: password);
      _sync(currentUserId: user.id);
      state = state.copyWith(activeExperience: AppExperience.guest);
    });
  }

  Future<void> signInDemo({bool asHost = false}) async {
    await _run(() async {
      final user = await _repository.signInDemo(asHost: asHost);
      _sync(currentUserId: user.id);
      state = state.copyWith(
        activeExperience: asHost ? AppExperience.host : AppExperience.guest,
      );
    });
  }

  Future<void> register(SignUpDraft draft) async {
    await _run(() async {
      final user = await _repository.register(draft);
      _sync(currentUserId: user.id);
      state = state.copyWith(activeExperience: AppExperience.guest);
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = state.copyWith(
      clearCurrentUser: true,
      clearLastSwiped: true,
      activeExperience: AppExperience.guest,
    );
  }

  void setActiveExperience(AppExperience experience) {
    state = state.copyWith(activeExperience: experience);
  }

  Future<void> completeOnboarding(ProfileUpdateDraft draft) async {
    final user = _requireUser();
    await _run(() async {
      final updated = await _repository.completeOnboarding(user.id, draft);
      _sync(currentUserId: updated.id);
    });
  }

  Future<void> updateProfile(ProfileUpdateDraft draft) async {
    final user = _requireUser();
    await _run(() async {
      final updated = await _repository.updateProfile(user.id, draft);
      _sync(currentUserId: updated.id);
    });
  }

  Future<void> addFriend(String friendId) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.addFriend(user.id, friendId);
      _sync(currentUserId: user.id);
    });
  }

  Future<void> removeFriend(String friendId) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.removeFriend(user.id, friendId);
      _sync(currentUserId: user.id);
    });
  }

  Future<void> deleteAccount() async {
    final user = _requireUser();
    await _run(() async {
      await _repository.deleteAccount(user.id);
      _sync();
      state = state.copyWith(clearCurrentUser: true);
    });
  }

  void updateFilter(DiscoverFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> createEvent(CreateEventDraft draft) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.createEvent(user.id, draft);
      _sync(currentUserId: user.id);
      state = state.copyWith(activeExperience: AppExperience.host);
    });
  }

  Future<void> requestToJoin(String eventId, JoinEventDraft draft) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.requestToJoin(user.id, eventId, draft);
      _sync(currentUserId: user.id, lastSwipedEventId: eventId);
    });
  }

  Future<void> withdrawRequest(String requestId) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.withdrawRequest(user.id, requestId);
      _sync(currentUserId: user.id, clearLastSwiped: true);
    });
  }

  Future<void> passEvent(String eventId) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.passEvent(user.id, eventId);
      _sync(currentUserId: user.id, lastSwipedEventId: eventId);
    });
  }

  Future<void> undoLastSwipe() async {
    final user = _requireUser();
    final last = state.lastSwipedEventId;
    if (last == null || !user.isPremium) {
      state = state.copyWith(
        errorMessage: 'Undo is a Premium feature in the MVP demo.',
      );
      return;
    }
    await _run(() async {
      await _repository.undoSwipe(user.id, last);
      _sync(currentUserId: user.id, clearLastSwiped: true);
    });
  }

  Future<void> acceptRequest(String requestId) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.acceptRequest(user.id, requestId);
      _sync(currentUserId: user.id);
    });
  }

  Future<void> rejectRequest(String requestId, {String? reason}) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.rejectRequest(user.id, requestId, reason: reason);
      _sync(currentUserId: user.id);
    });
  }

  Future<void> updateEventAccess({
    required String eventId,
    required String exactAddress,
    required String accessInstructions,
  }) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.updateEventAccess(
        user.id,
        eventId,
        exactAddress: exactAddress,
        accessInstructions: accessInstructions,
      );
      _sync(currentUserId: user.id);
    });
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final user = _requireUser();
    if (text.trim().isEmpty) return;
    await _run(() async {
      await _repository.sendMessage(user.id, conversationId, text);
      _sync(currentUserId: user.id);
    });
  }

  Future<void> report({
    String? reportedUserId,
    String? reportedEventId,
    String? reportedMessageId,
    required ReportReason reason,
    required String description,
  }) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.reportContent(
        reporterId: user.id,
        reportedUserId: reportedUserId,
        reportedEventId: reportedEventId,
        reportedMessageId: reportedMessageId,
        reasonName: reason.name,
        description: description,
      );
      _sync(currentUserId: user.id);
    });
  }

  Future<void> blockUser(String blockedUserId) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.blockUser(user.id, blockedUserId);
      _sync(currentUserId: user.id);
    });
  }

  Future<void> unblockUser(String blockedUserId) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.unblockUser(user.id, blockedUserId);
      _sync(currentUserId: user.id);
    });
  }

  Future<void> markNotificationsRead() async {
    final user = _requireUser();
    await _repository.markNotificationsRead(user.id);
    _sync(currentUserId: user.id);
  }

  Future<void> requestDj(String djId, String eventId) async {
    final user = _requireUser();
    await _run(() async {
      await _repository.requestDj(
        hostId: user.id,
        djId: djId,
        eventId: eventId,
        message: '${user.firstName} wants to book you for a PULLUP night plan.',
      );
      _sync(currentUserId: user.id);
    });
  }

  PartyEvent? eventById(String id) {
    for (final event in state.events) {
      if (event.id == id) return event;
    }
    return null;
  }

  UserProfile? userById(String id) {
    for (final user in state.users) {
      if (user.id == id) return user;
    }
    return null;
  }

  ChatConversation? conversationById(String id) {
    for (final conversation in state.conversations) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  List<ChatMessage> messagesForConversation(String conversationId) {
    return state.messages
        .where((message) => message.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<EventRequest> requestsForEvent(String eventId) {
    return state.requests
        .where((request) => request.eventId == eventId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  UserProfile _requireUser() {
    final user = state.currentUser;
    if (user == null) {
      throw const AppException('Session expired. Please sign in again.');
    }
    return user;
  }

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await action();
      state = state.copyWith(loading: false, clearError: true);
    } on AppException catch (error) {
      state = state.copyWith(loading: false, errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Unexpected error: $error',
      );
    }
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _repository.restoreSession();
      _sync(currentUserId: user?.id);
    } on AppException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } catch (_) {
      // A failed local restore should never block the sign-in screen.
    }
  }

  void _sync({
    String? currentUserId,
    String? lastSwipedEventId,
    bool clearLastSwiped = false,
  }) {
    final snapshot = _repository.snapshot;
    final previousId = currentUserId ?? state.currentUser?.id;
    final currentUser = previousId == null
        ? null
        : snapshot.users.where((user) => user.id == previousId).firstOrNull;
    state = state.copyWith(
      currentUser: currentUser,
      clearCurrentUser: currentUser == null,
      users: snapshot.users,
      events: snapshot.events,
      requests: snapshot.requests,
      matches: snapshot.matches,
      conversations: snapshot.conversations,
      messages: snapshot.messages,
      notifications: snapshot.notifications,
      reports: snapshot.reports,
      djProfiles: snapshot.djProfiles,
      swipedEventIds: snapshot.swipedEventIds,
      rejectedEventIds: snapshot.rejectedEventIds,
      lastSwipedEventId: lastSwipedEventId,
      clearLastSwiped: clearLastSwiped,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
