import '../../../core/errors/app_exception.dart';
import '../../../models/chat.dart';
import '../../../models/event_request.dart';
import '../../../models/party_event.dart';
import '../../../models/pullup_match.dart';
import '../../../models/report.dart';
import '../../../models/user_profile.dart';
import '../domain/app_drafts.dart';
import '../domain/pullup_repository.dart';

class FirebasePullupRepository implements PullupRepository {
  const FirebasePullupRepository();

  @override
  PullupSnapshot get snapshot => throw const AppException(
    'Firebase repository needs Firebase project credentials and collection setup.',
  );

  @override
  Future<PullupMatch> acceptRequest(String hostId, String requestId) =>
      _notConfigured();

  @override
  Future<UserProfile> blockUser(String userId, String blockedUserId) =>
      _notConfigured();

  @override
  Future<UserProfile> addFriend(String userId, String friendId) =>
      _notConfigured();

  @override
  Future<UserProfile> completeOnboarding(
    String userId,
    ProfileUpdateDraft draft,
  ) => _notConfigured();

  @override
  Future<PartyEvent> createEvent(String hostId, CreateEventDraft draft) =>
      _notConfigured();

  @override
  Future<void> deleteAccount(String userId) => _notConfigured();

  @override
  Future<void> markNotificationsRead(String userId) => _notConfigured();

  @override
  Future<void> passEvent(String userId, String eventId) => _notConfigured();

  @override
  Future<void> likeEvent(String userId, String eventId) => _notConfigured();

  @override
  Future<EventRequest> applyAsProfessional(
    String userId,
    String eventId, {
    required String message,
  }) => _notConfigured();

  @override
  Future<EventRequest> rejectRequest(
    String hostId,
    String requestId, {
    String? reason,
  }) => _notConfigured();

  @override
  Future<Report> reportContent({
    required String reporterId,
    String? reportedUserId,
    String? reportedEventId,
    String? reportedMessageId,
    required String reasonName,
    required String description,
  }) => _notConfigured();

  @override
  Future<EventRequest> requestToJoin(
    String userId,
    String eventId,
    JoinEventDraft draft,
  ) => _notConfigured();

  @override
  Future<UserProfile> removeFriend(String userId, String friendId) =>
      _notConfigured();

  @override
  Future<void> requestDj({
    required String hostId,
    required String djId,
    required String eventId,
    required String message,
  }) => _notConfigured();

  @override
  Future<ChatMessage> sendMessage(
    String userId,
    String conversationId,
    String text,
  ) => _notConfigured();

  @override
  Future<UserProfile?> restoreSession() => _notConfigured();

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) => _notConfigured();

  @override
  Future<UserProfile> signInDemo({required bool asHost}) => _notConfigured();

  @override
  Future<void> signOut() => _notConfigured();

  @override
  Future<UserProfile> register(SignUpDraft draft) => _notConfigured();

  @override
  Future<void> undoSwipe(String userId, String eventId) => _notConfigured();

  @override
  Future<PartyEvent> updateEventAccess(
    String hostId,
    String eventId, {
    required String exactAddress,
    required String accessInstructions,
  }) => _notConfigured();

  @override
  Future<EventRequest> withdrawRequest(String userId, String requestId) =>
      _notConfigured();

  @override
  Future<UserProfile> unblockUser(String userId, String blockedUserId) =>
      _notConfigured();

  @override
  Future<UserProfile> updateProfile(String userId, ProfileUpdateDraft draft) =>
      _notConfigured();

  Future<T> _notConfigured<T>() {
    throw const AppException(
      'Firebase mode is prepared but not configured. Use the demo repository or add Firebase credentials.',
    );
  }
}
