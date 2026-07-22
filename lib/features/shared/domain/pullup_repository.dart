import '../../../models/chat.dart';
import '../../../models/dj.dart';
import '../../../models/event_request.dart';
import '../../../models/notification_item.dart';
import '../../../models/party_event.dart';
import '../../../models/pullup_match.dart';
import '../../../models/report.dart';
import '../../../models/user_profile.dart';
import 'app_drafts.dart';

class PullupSnapshot {
  const PullupSnapshot({
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
  });

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
}

abstract class PullupRepository {
  PullupSnapshot get snapshot;

  Future<UserProfile?> restoreSession();

  Future<UserProfile> signIn({required String email, required String password});

  Future<UserProfile> signInDemo({required bool asHost});

  Future<void> signOut();

  Future<UserProfile> register(SignUpDraft draft);

  Future<UserProfile> updateProfile(String userId, ProfileUpdateDraft draft);

  Future<UserProfile> addFriend(String userId, String friendId);

  Future<UserProfile> removeFriend(String userId, String friendId);

  Future<UserProfile> completeOnboarding(
    String userId,
    ProfileUpdateDraft draft,
  );

  Future<void> deleteAccount(String userId);

  Future<PartyEvent> createEvent(String hostId, CreateEventDraft draft);

  Future<EventRequest> requestToJoin(
    String userId,
    String eventId,
    JoinEventDraft draft,
  );

  Future<EventRequest> withdrawRequest(String userId, String requestId);

  Future<void> passEvent(String userId, String eventId);

  Future<void> likeEvent(String userId, String eventId);

  Future<EventRequest> applyAsProfessional(
    String userId,
    String eventId, {
    required String message,
  });

  Future<void> undoSwipe(String userId, String eventId);

  Future<PullupMatch> acceptRequest(String hostId, String requestId);

  Future<EventRequest> rejectRequest(
    String hostId,
    String requestId, {
    String? reason,
  });

  Future<PartyEvent> updateEventAccess(
    String hostId,
    String eventId, {
    required String exactAddress,
    required String accessInstructions,
  });

  Future<ChatMessage> sendMessage(
    String userId,
    String conversationId,
    String text,
  );

  Future<Report> reportContent({
    required String reporterId,
    String? reportedUserId,
    String? reportedEventId,
    String? reportedMessageId,
    required String reasonName,
    required String description,
  });

  Future<UserProfile> blockUser(String userId, String blockedUserId);

  Future<UserProfile> unblockUser(String userId, String blockedUserId);

  Future<void> markNotificationsRead(String userId);

  Future<void> requestDj({
    required String hostId,
    required String djId,
    required String eventId,
    required String message,
  });
}
