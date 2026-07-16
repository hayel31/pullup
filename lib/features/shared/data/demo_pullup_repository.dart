import '../../../core/errors/app_exception.dart';
import '../../../models/chat.dart';
import '../../../models/dj.dart';
import '../../../models/enums.dart';
import '../../../models/event_request.dart';
import '../../../models/geo_point_lite.dart';
import '../../../models/notification_item.dart';
import '../../../models/party_event.dart';
import '../../../models/pullup_match.dart';
import '../../../models/report.dart';
import '../../../models/user_profile.dart';
import '../domain/app_drafts.dart';
import '../domain/pullup_repository.dart';
import 'demo_seed.dart';

class DemoPullupRepository implements PullupRepository {
  DemoPullupRepository() {
    final seed = DemoSeed.build();
    _users = [...seed.users];
    _events = [...seed.events];
    _requests = [...seed.requests];
    _matches = [...seed.matches];
    _conversations = [...seed.conversations];
    _messages = [...seed.messages];
    _notifications = [...seed.notifications];
    _reports = [...seed.reports];
    _djProfiles = [...seed.djProfiles];
    _swipedEventIds = Map<String, Set<String>>.from(seed.swipedEventIds);
    _rejectedEventIds = Map<String, Set<String>>.from(seed.rejectedEventIds);
  }

  late List<UserProfile> _users;
  late List<PartyEvent> _events;
  late List<EventRequest> _requests;
  late List<PullupMatch> _matches;
  late List<ChatConversation> _conversations;
  late List<ChatMessage> _messages;
  late List<NotificationItem> _notifications;
  late List<Report> _reports;
  late List<DjProfile> _djProfiles;
  late Map<String, Set<String>> _swipedEventIds;
  late Map<String, Set<String>> _rejectedEventIds;

  int _counter = 1000;

  @override
  PullupSnapshot get snapshot => PullupSnapshot(
    users: List.unmodifiable(_users),
    events: List.unmodifiable(_events),
    requests: List.unmodifiable(_requests),
    matches: List.unmodifiable(_matches),
    conversations: List.unmodifiable(_conversations),
    messages: List.unmodifiable(_messages),
    notifications: List.unmodifiable(_notifications),
    reports: List.unmodifiable(_reports),
    djProfiles: List.unmodifiable(_djProfiles),
    swipedEventIds: _swipedEventIds.map(
      (key, value) => MapEntry(key, Set.unmodifiable(value)),
    ),
    rejectedEventIds: _rejectedEventIds.map(
      (key, value) => MapEntry(key, Set.unmodifiable(value)),
    ),
  );

  @override
  Future<UserProfile> signInDemo({required bool asHost}) async {
    final user = _users.firstWhere(
      (user) => user.id == (asHost ? 'host-001' : 'user-001'),
    );
    return _touchUser(user.id);
  }

  @override
  Future<UserProfile> register(SignUpDraft draft) async {
    if (!draft.acceptedTerms || !draft.confirmedMinimumAge) {
      throw const AppException(
        'You must accept the rules and confirm the minimum age.',
      );
    }
    if (_users.any(
      (user) => user.email.toLowerCase() == draft.email.toLowerCase(),
    )) {
      throw const AppException('This email is already registered.');
    }
    final now = DateTime.now();
    final id = 'user-${_nextId()}';
    final user = UserProfile(
      id: id,
      email: draft.email,
      displayName: draft.displayName,
      firstName: draft.firstName,
      lastName: draft.lastName,
      birthDate: draft.birthDate,
      gender: draft.gender,
      city: draft.city,
      approximateLocation: const GeoPointLite(
        latitude: 48.8566,
        longitude: 2.3522,
      ),
      profilePhotos: const [],
      mainPhotoUrl: null,
      interests: const [],
      musicPreferences: const [],
      languages: const [],
      verificationStatus: VerificationStatus.email,
      phoneVerified: false,
      selfieVerified: false,
      identityVerified: false,
      isPremium: false,
      isDj: false,
      isHost: false,
      hostRating: 0,
      hostedEventCount: 0,
      guestAttendanceCount: 0,
      reportCount: 0,
      blockedUserIds: const [],
      createdAt: now,
      updatedAt: now,
      lastActiveAt: now,
      accountStatus: AccountStatus.active,
      onboardingCompleted: false,
    );
    _users.add(user);
    return user;
  }

  @override
  Future<UserProfile> updateProfile(
    String userId,
    ProfileUpdateDraft draft,
  ) async {
    return _updateUser(
      userId,
      (user) => user.copyWith(
        displayName: draft.displayName,
        bio: draft.bio,
        city: draft.city,
        interests: draft.interests,
        musicPreferences: draft.musicPreferences,
        languages: draft.languages,
        profilePhotos: draft.profilePhotos,
        mainPhotoUrl: draft.profilePhotos.isEmpty
            ? user.mainPhotoUrl
            : draft.profilePhotos.first,
        occupation: draft.occupation,
        instagramHandle: draft.instagramHandle,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<UserProfile> completeOnboarding(
    String userId,
    ProfileUpdateDraft draft,
  ) async {
    if (draft.profilePhotos.isEmpty) {
      throw const AppException('Add at least one profile photo.');
    }
    final updated = await updateProfile(userId, draft);
    return _updateUser(
      userId,
      (user) => updated.copyWith(onboardingCompleted: true),
    );
  }

  @override
  Future<void> deleteAccount(String userId) async {
    _updateUser(
      userId,
      (user) => user.copyWith(accountStatus: AccountStatus.deleted),
    );
  }

  @override
  Future<PartyEvent> createEvent(String hostId, CreateEventDraft draft) async {
    final host = _userById(hostId);
    final now = DateTime.now();
    final event = PartyEvent(
      id: 'event-${_nextId()}',
      hostId: hostId,
      hostPreview: HostPreview(
        id: host.id,
        firstName: host.firstName,
        photoUrl:
            host.mainPhotoUrl ??
            'https://picsum.photos/seed/${host.id}/900/1200',
        badges: host.badges,
        hostedEventCount: host.hostedEventCount + 1,
      ),
      title: draft.title,
      description: draft.description,
      category: draft.category,
      coverPhotoUrl: draft.coverPhotoUrl,
      photoUrls: draft.photoUrls,
      city: draft.city,
      areaName: draft.areaName,
      approximateGeoPoint: draft.approximateGeoPoint,
      exactAddress: draft.exactAddress,
      accessInstructions: draft.accessInstructions,
      startDateTime: draft.startDateTime,
      endDateTime: draft.endDateTime,
      timezone: draft.timezone,
      ageRequirement: draft.ageRequirement,
      maxParticipants: draft.maxParticipants,
      availableSpots: draft.maxParticipants,
      acceptedParticipantIds: const [],
      waitingParticipantIds: const [],
      rejectedParticipantIds: const [],
      eventTags: draft.eventTags,
      musicGenres: draft.musicGenres,
      dressCode: draft.dressCode,
      contributionText: draft.contributionText,
      houseRules: draft.houseRules,
      alcoholPolicy: draft.alcoholPolicy,
      smokingPolicy: draft.smokingPolicy,
      visibility: draft.visibility,
      status: EventStatus.published,
      approvalMode: draft.approvalMode,
      allowsGroups: draft.allowsGroups,
      maxGroupSize: draft.maxGroupSize,
      isBoosted: false,
      likeCount: 0,
      requestCount: 0,
      matchCount: 0,
      createdAt: now,
      updatedAt: now,
      expiresAt: draft.endDateTime.add(const Duration(hours: 2)),
    );
    _events.add(event);
    _updateUser(
      hostId,
      (user) => user.copyWith(
        isHost: true,
        hostedEventCount: user.hostedEventCount + 1,
        updatedAt: now,
      ),
    );
    return event;
  }

  @override
  Future<EventRequest> requestToJoin(
    String userId,
    String eventId,
    JoinEventDraft draft,
  ) async {
    final event = _eventById(eventId);
    if (event.hostId == userId) {
      throw const AppException('Hosts cannot request their own event.');
    }
    if (draft.groupSize < 1 || draft.groupSize > event.maxGroupSize) {
      throw AppException(
        'This host accepts groups up to ${event.maxGroupSize}.',
      );
    }
    if (draft.groupSize > event.availableSpots) {
      throw const AppException('Not enough spots left for this group.');
    }
    final duplicate = _requests.any(
      (request) =>
          request.eventId == eventId &&
          request.requesterId == userId &&
          request.status != RequestStatus.rejected &&
          request.status != RequestStatus.withdrawn,
    );
    if (duplicate) {
      throw const AppException('You already sent a request for this event.');
    }
    final request = EventRequest(
      id: 'request-${_nextId()}',
      eventId: eventId,
      hostId: event.hostId,
      requesterId: userId,
      note: draft.note,
      groupSize: draft.groupSize,
      companionNames: draft.companionNames,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
    );
    _requests.add(request);
    _swipedEventIds.putIfAbsent(userId, () => <String>{}).add(eventId);
    _replaceEvent(
      event.copyWith(
        waitingParticipantIds: [...event.waitingParticipantIds, userId],
        requestCount: event.requestCount + 1,
        updatedAt: DateTime.now(),
      ),
    );
    _notifications.add(
      NotificationItem(
        id: 'notification-${_nextId()}',
        userId: event.hostId,
        type: NotificationType.requestReceived,
        title: 'New request',
        body: '${_userById(userId).firstName} wants to join ${event.title}.',
        createdAt: DateTime.now(),
        read: false,
        eventId: eventId,
      ),
    );
    if (event.approvalMode == ApprovalMode.automatic) {
      await acceptRequest(event.hostId, request.id);
      return _requestById(request.id);
    }
    return request;
  }

  @override
  Future<EventRequest> withdrawRequest(String userId, String requestId) async {
    final request = _requestById(requestId);
    if (request.requesterId != userId) {
      throw const AppException('You can only withdraw your own request.');
    }
    if (request.status != RequestStatus.pending) {
      throw const AppException('Only pending requests can be withdrawn.');
    }

    final now = DateTime.now();
    final updated = request.copyWith(
      status: RequestStatus.withdrawn,
      decidedAt: now,
    );
    final event = _eventById(request.eventId);
    _replaceRequest(updated);
    _replaceEvent(
      event.copyWith(
        waitingParticipantIds: event.waitingParticipantIds
            .where((id) => id != userId)
            .toList(),
        requestCount: event.requestCount > 0 ? event.requestCount - 1 : 0,
        updatedAt: now,
      ),
    );
    _swipedEventIds[userId]?.remove(event.id);
    return updated;
  }

  @override
  Future<void> passEvent(String userId, String eventId) async {
    _swipedEventIds.putIfAbsent(userId, () => <String>{}).add(eventId);
    _rejectedEventIds.putIfAbsent(userId, () => <String>{}).add(eventId);
  }

  @override
  Future<void> undoSwipe(String userId, String eventId) async {
    _swipedEventIds[userId]?.remove(eventId);
    _rejectedEventIds[userId]?.remove(eventId);
  }

  @override
  Future<PullupMatch> acceptRequest(String hostId, String requestId) async {
    final request = _requestById(requestId);
    final event = _eventById(request.eventId);
    if (event.hostId != hostId) {
      throw const AppException('Only the host can accept this request.');
    }
    if (request.status != RequestStatus.pending) {
      throw const AppException('This request is no longer pending.');
    }
    if (event.availableSpots < request.groupSize) {
      throw const AppException('Not enough spots left.');
    }
    final now = DateTime.now();
    final updatedRequest = request.copyWith(
      status: RequestStatus.accepted,
      decidedAt: now,
    );
    _replaceRequest(updatedRequest);
    final remaining = event.availableSpots - request.groupSize;
    _replaceEvent(
      event.copyWith(
        acceptedParticipantIds: [
          ...event.acceptedParticipantIds,
          request.requesterId,
        ],
        waitingParticipantIds: event.waitingParticipantIds
            .where((id) => id != request.requesterId)
            .toList(),
        availableSpots: remaining,
        status: remaining == 0 ? EventStatus.full : event.status,
        matchCount: event.matchCount + 1,
        updatedAt: now,
      ),
    );

    final conversation = ChatConversation(
      id: 'conversation-${_nextId()}',
      eventId: event.id,
      memberIds: [request.requesterId, hostId],
      lastMessagePreview: 'Exact address unlocked.',
      updatedAt: now,
      unreadByUserIds: [request.requesterId],
    );
    _conversations.add(conversation);
    _messages.addAll([
      ChatMessage(
        id: 'message-${_nextId()}',
        conversationId: conversation.id,
        senderId: 'system',
        type: MessageType.system,
        text: 'Match created for ${event.title}.',
        createdAt: now,
        readByUserIds: [hostId],
      ),
      ChatMessage(
        id: 'message-${_nextId()}',
        conversationId: conversation.id,
        senderId: 'system',
        type: MessageType.system,
        text: 'Exact address unlocked. Address: ${event.exactAddress}.',
        createdAt: now.add(const Duration(seconds: 1)),
        readByUserIds: [hostId],
      ),
    ]);
    final match = PullupMatch(
      id: 'match-${_nextId()}',
      userId: request.requesterId,
      hostId: hostId,
      eventId: event.id,
      conversationId: conversation.id,
      status: MatchStatus.active,
      createdAt: now,
      isNew: true,
    );
    _matches.add(match);
    _notifications.add(
      NotificationItem(
        id: 'notification-${_nextId()}',
        userId: request.requesterId,
        type: NotificationType.requestAccepted,
        title: 'You are in',
        body: '${event.hostPreview.firstName} accepted you for ${event.title}.',
        createdAt: now,
        read: false,
        eventId: event.id,
        conversationId: conversation.id,
      ),
    );
    return match;
  }

  @override
  Future<EventRequest> rejectRequest(
    String hostId,
    String requestId, {
    String? reason,
  }) async {
    final request = _requestById(requestId);
    final event = _eventById(request.eventId);
    if (event.hostId != hostId) {
      throw const AppException('Only the host can reject this request.');
    }
    if (request.status != RequestStatus.pending) {
      throw const AppException('This request is no longer pending.');
    }
    final updated = request.copyWith(
      status: RequestStatus.rejected,
      decidedAt: DateTime.now(),
      decisionReason: reason?.trim(),
    );
    _replaceRequest(updated);
    _replaceEvent(
      event.copyWith(
        waitingParticipantIds: event.waitingParticipantIds
            .where((id) => id != request.requesterId)
            .toList(),
        rejectedParticipantIds: [
          ...event.rejectedParticipantIds,
          request.requesterId,
        ],
        updatedAt: DateTime.now(),
      ),
    );
    _notifications.add(
      NotificationItem(
        id: 'notification-${_nextId()}',
        userId: request.requesterId,
        type: NotificationType.requestRejected,
        title: 'Request update',
        body: 'This plan did not work out this time.',
        createdAt: DateTime.now(),
        read: false,
        eventId: event.id,
      ),
    );
    return updated;
  }

  @override
  Future<PartyEvent> updateEventAccess(
    String hostId,
    String eventId, {
    required String exactAddress,
    required String accessInstructions,
  }) async {
    final event = _eventById(eventId);
    if (event.hostId != hostId) {
      throw const AppException('Only the host can update private access.');
    }
    if (exactAddress.trim().isEmpty) {
      throw const AppException('Add an exact address before saving access.');
    }
    final now = DateTime.now();
    final updated = event.copyWith(
      exactAddress: exactAddress.trim(),
      accessInstructions: accessInstructions.trim(),
      updatedAt: now,
    );
    _replaceEvent(updated);
    for (final guestId in event.acceptedParticipantIds) {
      _notifications.add(
        NotificationItem(
          id: 'notification-${_nextId()}',
          userId: guestId,
          type: NotificationType.addressUnlocked,
          title: 'Access updated',
          body: 'Private access details changed for ${event.title}.',
          createdAt: now,
          read: false,
          eventId: event.id,
        ),
      );
    }
    return updated;
  }

  @override
  Future<ChatMessage> sendMessage(
    String userId,
    String conversationId,
    String text,
  ) async {
    final conversation = _conversationById(conversationId);
    if (!conversation.memberIds.contains(userId)) {
      throw const AppException(
        'You are not allowed to access this conversation.',
      );
    }
    final blocked = conversation.memberIds.any((id) {
      if (id == userId) return false;
      return _userById(id).blockedUserIds.contains(userId) ||
          _userById(userId).blockedUserIds.contains(id);
    });
    if (blocked) {
      throw const AppException('Messaging is blocked between these users.');
    }
    final now = DateTime.now();
    final message = ChatMessage(
      id: 'message-${_nextId()}',
      conversationId: conversationId,
      senderId: userId,
      type: MessageType.text,
      text: text.trim(),
      createdAt: now,
      readByUserIds: [userId],
    );
    _messages.add(message);
    _replaceConversation(
      conversation.copyWith(
        lastMessagePreview: text.trim(),
        updatedAt: now,
        unreadByUserIds: conversation.memberIds
            .where((id) => id != userId)
            .toList(),
      ),
    );
    return message;
  }

  @override
  Future<Report> reportContent({
    required String reporterId,
    String? reportedUserId,
    String? reportedEventId,
    String? reportedMessageId,
    required String reasonName,
    required String description,
  }) async {
    final reason = ReportReason.values.firstWhere(
      (reason) => reason.name == reasonName,
      orElse: () => ReportReason.other,
    );
    final report = Report(
      id: 'report-${_nextId()}',
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      reportedEventId: reportedEventId,
      reportedMessageId: reportedMessageId,
      reason: reason,
      description: description,
      evidenceUrls: const [],
      status: ReportStatus.submitted,
      createdAt: DateTime.now(),
    );
    _reports.add(report);
    return report;
  }

  @override
  Future<UserProfile> blockUser(String userId, String blockedUserId) async {
    return _updateUser(
      userId,
      (user) => user.copyWith(
        blockedUserIds: {...user.blockedUserIds, blockedUserId}.toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<UserProfile> unblockUser(String userId, String blockedUserId) async {
    return _updateUser(
      userId,
      (user) => user.copyWith(
        blockedUserIds: user.blockedUserIds
            .where((id) => id != blockedUserId)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> markNotificationsRead(String userId) async {
    _notifications = _notifications
        .map(
          (notification) => notification.userId == userId
              ? notification.copyWith(read: true)
              : notification,
        )
        .toList();
  }

  @override
  Future<void> requestDj({
    required String hostId,
    required String djId,
    required String eventId,
    required String message,
  }) async {
    _notifications.add(
      NotificationItem(
        id: 'notification-${_nextId()}',
        userId: _djProfiles.firstWhere((dj) => dj.id == djId).userId,
        type: NotificationType.djRequest,
        title: 'DJ request',
        body: message,
        createdAt: DateTime.now(),
        read: false,
        eventId: eventId,
      ),
    );
  }

  String _nextId() => (_counter++).toString();

  UserProfile _userById(String id) => _users.firstWhere(
    (user) => user.id == id,
    orElse: () => throw const AppException('User not found.'),
  );

  PartyEvent _eventById(String id) => _events.firstWhere(
    (event) => event.id == id,
    orElse: () => throw const AppException('Event not found.'),
  );

  EventRequest _requestById(String id) => _requests.firstWhere(
    (request) => request.id == id,
    orElse: () => throw const AppException('Request not found.'),
  );

  ChatConversation _conversationById(String id) => _conversations.firstWhere(
    (conversation) => conversation.id == id,
    orElse: () => throw const AppException('Conversation not found.'),
  );

  UserProfile _touchUser(String id) {
    return _updateUser(
      id,
      (user) => user.copyWith(lastActiveAt: DateTime.now()),
    );
  }

  UserProfile _updateUser(
    String id,
    UserProfile Function(UserProfile user) update,
  ) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index == -1) {
      throw const AppException('User not found.');
    }
    final next = update(_users[index]);
    _users[index] = next;
    return next;
  }

  void _replaceEvent(PartyEvent event) {
    final index = _events.indexWhere((item) => item.id == event.id);
    if (index == -1) throw const AppException('Event not found.');
    _events[index] = event;
  }

  void _replaceRequest(EventRequest request) {
    final index = _requests.indexWhere((item) => item.id == request.id);
    if (index == -1) throw const AppException('Request not found.');
    _requests[index] = request;
  }

  void _replaceConversation(ChatConversation conversation) {
    final index = _conversations.indexWhere(
      (item) => item.id == conversation.id,
    );
    if (index == -1) throw const AppException('Conversation not found.');
    _conversations[index] = conversation;
  }
}
