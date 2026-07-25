import '../../../core/errors/app_exception.dart';
import '../../../models/chat.dart';
import '../../../models/dj.dart';
import '../../../models/enums.dart';
import '../../../models/event_request.dart';
import '../../../models/geo_point_lite.dart';
import '../../../models/notification_item.dart';
import '../../../models/party_event.dart';
import '../../../models/pullup_match.dart';
import '../../../models/professional_profile.dart';
import '../../../models/report.dart';
import '../../../models/user_profile.dart';
import '../domain/app_drafts.dart';
import '../domain/demo_account.dart';
import '../domain/pullup_repository.dart';
import 'demo_local_store.dart';
import 'demo_seed.dart';

class DemoPullupRepository implements PullupRepository {
  DemoPullupRepository({DemoLocalStore? localStore})
    : _localStore = localStore ?? DemoLocalStore() {
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
    _seedUsersById = {for (final user in seed.users) user.id: user};
    _seedEventsById = {for (final event in seed.events) event.id: event};
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
  late final Map<String, UserProfile> _seedUsersById;
  late final Map<String, PartyEvent> _seedEventsById;
  final DemoLocalStore _localStore;
  final Set<String> _createdEventIds = {};
  List<StoredCredential> _credentials = const [];
  Future<void>? _hydration;

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
  Future<UserProfile?> restoreSession() async {
    await _ensureHydrated();
    final persisted = await _localStore.load();
    final userId = persisted.sessionUserId;
    if (userId == null) return null;
    final user = _findUser(userId);
    if (user == null || user.accountStatus != AccountStatus.active) {
      await _localStore.clearSession();
      return null;
    }
    final touched = _touchUser(user.id);
    await _localStore.saveUser(touched);
    return touched;
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureHydrated();
    final normalizedEmail = email.toLowerCase().trim();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const AppException('Enter your email and password.');
    }

    String? userId;
    for (final account in demoAccounts) {
      if (account.email == normalizedEmail && account.password == password) {
        userId = account.userId;
        break;
      }
    }
    if (userId == null) {
      for (final credential in _credentials) {
        if (credential.email == normalizedEmail &&
            credential.matches(password)) {
          userId = credential.userId;
          break;
        }
      }
    }
    if (userId == null) {
      throw const AppException('Incorrect email or password.');
    }

    final user = _userById(userId);
    if (user.accountStatus != AccountStatus.active) {
      throw const AppException('This account is not available.');
    }
    final touched = _touchUser(user.id);
    await _localStore.saveUser(touched);
    await _localStore.saveSession(touched.id);
    return touched;
  }

  @override
  Future<UserProfile> signInDemo({required bool asHost}) async {
    await _ensureHydrated();
    final user = _users.firstWhere(
      (user) => user.id == (asHost ? 'host-001' : 'user-001'),
    );
    final touched = _touchUser(user.id);
    await _localStore.saveUser(touched);
    await _localStore.saveSession(touched.id);
    return touched;
  }

  @override
  Future<void> signOut() async {
    await _localStore.clearSession();
  }

  @override
  Future<UserProfile> register(SignUpDraft draft) async {
    await _ensureHydrated();
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
    if (draft.password.length < 8) {
      throw const AppException('Password must contain at least 8 characters.');
    }
    final now = DateTime.now();
    final id = draft.accountType == AccountType.professional
        ? 'pro-${now.microsecondsSinceEpoch}'
        : 'user-${now.microsecondsSinceEpoch}';
    final initialProfessionalProfile =
        draft.accountType == AccountType.professional
        ? ProfessionalProfile(
            category: draft.professionalCategory ?? ProfessionalCategory.other,
            businessName: draft.displayName,
            headline: '',
            description: '',
            services: const [],
            portfolioItems: const [],
            completedProjects: const [],
            establishments: const [],
            socialLinks: const {},
            travelRadiusKm: 25,
            availability: '',
            isVerified: false,
          )
        : null;
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
        latitude: 43.6047,
        longitude: 1.4442,
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
      isDj: draft.professionalCategory == ProfessionalCategory.dj,
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
      accountType: draft.accountType,
      professionalProfile: initialProfessionalProfile,
    );
    _users.add(user);
    final credential = StoredCredential.create(
      userId: id,
      email: draft.email,
      password: draft.password,
    );
    _credentials = [..._credentials, credential];
    await _localStore.saveCredential(credential);
    await _localStore.saveUser(user);
    await _localStore.saveSession(user.id);
    return user;
  }

  @override
  Future<UserProfile> updateProfile(
    String userId,
    ProfileUpdateDraft draft,
  ) async {
    await _ensureHydrated();
    final updated = _updateUser(
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
        professionalProfile:
            draft.professionalProfile ?? user.professionalProfile,
        updatedAt: DateTime.now(),
      ),
    );
    await _localStore.saveUser(updated);
    return updated;
  }

  @override
  Future<UserProfile> addFriend(String userId, String friendId) async {
    await _ensureHydrated();
    if (userId == friendId) {
      throw const AppException('You cannot add yourself as a friend.');
    }
    final user = _userById(userId);
    final friend = _userById(friendId);
    if (user.blockedUserIds.contains(friendId) ||
        friend.blockedUserIds.contains(userId)) {
      throw const AppException('This friend connection is unavailable.');
    }
    final now = DateTime.now();
    final updatedUser = _updateUser(
      userId,
      (profile) => profile.copyWith(
        friendIds: {...profile.friendIds, friendId}.toList(),
        updatedAt: now,
      ),
    );
    final updatedFriend = _updateUser(
      friendId,
      (profile) => profile.copyWith(
        friendIds: {...profile.friendIds, userId}.toList(),
        updatedAt: now,
      ),
    );
    await _localStore.saveUser(updatedUser);
    await _localStore.saveUser(updatedFriend);
    return updatedUser;
  }

  @override
  Future<UserProfile> removeFriend(String userId, String friendId) async {
    await _ensureHydrated();
    _userById(userId);
    _userById(friendId);
    final now = DateTime.now();
    final updatedUser = _updateUser(
      userId,
      (profile) => profile.copyWith(
        friendIds: profile.friendIds.where((id) => id != friendId).toList(),
        updatedAt: now,
      ),
    );
    final updatedFriend = _updateUser(
      friendId,
      (profile) => profile.copyWith(
        friendIds: profile.friendIds.where((id) => id != userId).toList(),
        updatedAt: now,
      ),
    );
    await _localStore.saveUser(updatedUser);
    await _localStore.saveUser(updatedFriend);
    return updatedUser;
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
    final completed = _updateUser(
      userId,
      (user) => updated.copyWith(onboardingCompleted: true),
    );
    await _localStore.saveUser(completed);
    return completed;
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await _ensureHydrated();
    final updated = _updateUser(
      userId,
      (user) => user.copyWith(accountStatus: AccountStatus.deleted),
    );
    await _localStore.saveUser(updated);
    await _localStore.clearSession();
  }

  @override
  Future<PartyEvent> createEvent(String hostId, CreateEventDraft draft) async {
    await _ensureHydrated();
    final host = _userById(hostId);
    final now = DateTime.now();
    if (!draft.attendance.isValid ||
        draft.attendance.initialTotal < 1 ||
        draft.attendance.currentTotal != draft.attendance.initialTotal ||
        draft.attendance.initialTotal > draft.maxParticipants) {
      throw const AppException(
        'The initial guest mix must fit within the event capacity.',
      );
    }
    if (draft.entryFeeCents < 0) {
      throw const AppException('The entry price cannot be negative.');
    }
    final professionalProfile = draft.publishAsProfessional
        ? host.professionalProfile
        : null;
    final organizerType = professionalProfile == null
        ? EventOrganizerType.privateHost
        : professionalProfile.isVenue
        ? EventOrganizerType.venue
        : EventOrganizerType.professional;
    final event = PartyEvent(
      id: 'event-created-${now.microsecondsSinceEpoch}',
      hostId: hostId,
      hostPreview: HostPreview(
        id: host.id,
        firstName: host.firstName,
        photoUrl:
            host.mainPhotoUrl ??
            'https://picsum.photos/seed/${host.id}/900/1200',
        badges: host.badges,
        hostedEventCount: host.hostedEventCount + 1,
        accountType: host.accountType,
        professionalCategory: professionalProfile?.category,
        businessName: professionalProfile?.businessName,
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
      availableSpots: draft.maxParticipants - draft.attendance.initialTotal,
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
      organizerType: organizerType,
      guestInteractionMode: organizerType == EventOrganizerType.venue
          ? GuestInteractionMode.openInterest
          : GuestInteractionMode.approvalRequest,
      professionalNeeds: draft.professionalNeeds,
      attendance: draft.attendance,
      entryFeeCents: draft.entryFeeCents,
      foodPolicy: draft.foodPolicy,
      pillPolicy: draft.pillPolicy,
      illegalSubstancesProhibited: true,
    );
    _events.add(event);
    _createdEventIds.add(event.id);
    final updatedHost = _updateUser(
      hostId,
      (user) => user.copyWith(
        isHost: true,
        hostedEventCount: user.hostedEventCount + 1,
        updatedAt: now,
      ),
    );
    await _localStore.saveEvent(event);
    await _localStore.saveUser(updatedHost);
    return event;
  }

  @override
  Future<EventRequest> requestToJoin(
    String userId,
    String eventId,
    JoinEventDraft draft,
  ) async {
    await _ensureHydrated();
    final event = _eventById(eventId);
    if (event.hostId == userId) {
      throw const AppException('Hosts cannot request their own event.');
    }
    if (event.acceptsOpenInterest) {
      throw const AppException(
        'This professional event accepts likes without approval.',
      );
    }
    if (draft.groupSize < 1 || draft.groupSize > event.maxGroupSize) {
      throw AppException(
        'This host accepts groups up to ${event.maxGroupSize}.',
      );
    }
    if (draft.guestMenCount < 0 || draft.guestWomenCount < 0) {
      throw const AppException('Guest counts cannot be negative.');
    }
    final companionUserIds = draft.companionUserIds.toSet();
    if (companionUserIds.length != draft.companionUserIds.length) {
      throw const AppException('A friend can only be added once.');
    }
    final expectedGroupSize =
        1 +
        companionUserIds.length +
        draft.companionNames.length +
        draft.guestMenCount +
        draft.guestWomenCount;
    if (draft.groupSize != expectedGroupSize) {
      throw const AppException('The group details do not match its size.');
    }
    final requester = _userById(userId);
    for (final companionId in companionUserIds) {
      if (companionId == userId || companionId == event.hostId) {
        throw const AppException('This person cannot join this request.');
      }
      if (!requester.friendIds.contains(companionId)) {
        throw const AppException(
          'Only confirmed PULLUP friends can join your group.',
        );
      }
      final companion = _userById(companionId);
      if (requester.blockedUserIds.contains(companionId) ||
          companion.blockedUserIds.contains(userId) ||
          companion.blockedUserIds.contains(event.hostId)) {
        throw const AppException(
          'One selected friend is unavailable for this request.',
        );
      }
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
      companionUserIds: companionUserIds.toList(),
      guestMenCount: draft.guestMenCount,
      guestWomenCount: draft.guestWomenCount,
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
    await _persistEventIfCreated(eventId);
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
    await _ensureHydrated();
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
    await _persistEventIfCreated(event.id);
    return updated;
  }

  @override
  Future<void> passEvent(String userId, String eventId) async {
    await _ensureHydrated();
    _swipedEventIds.putIfAbsent(userId, () => <String>{}).add(eventId);
    _rejectedEventIds.putIfAbsent(userId, () => <String>{}).add(eventId);
  }

  @override
  Future<void> likeEvent(String userId, String eventId) async {
    await _ensureHydrated();
    final event = _eventById(eventId);
    if (event.hostId == userId) {
      throw const AppException('Hosts cannot like their own event.');
    }
    final swiped = _swipedEventIds.putIfAbsent(userId, () => <String>{});
    if (!swiped.add(eventId)) return;
    _replaceEvent(
      event.copyWith(likeCount: event.likeCount + 1, updatedAt: DateTime.now()),
    );
    await _persistEventIfCreated(eventId);
  }

  @override
  Future<EventRequest> applyAsProfessional(
    String userId,
    String eventId, {
    required String message,
  }) async {
    await _ensureHydrated();
    final user = _userById(userId);
    final profile = user.professionalProfile;
    if (!user.isProfessional || profile == null) {
      throw const AppException('Complete a professional profile first.');
    }
    final event = _eventById(eventId);
    if (event.hostId == userId) {
      throw const AppException('Hosts cannot apply to their own event.');
    }
    if (!event.professionalNeeds.contains(profile.category)) {
      throw const AppException(
        'This event is not looking for your professional category.',
      );
    }
    final duplicate = _requests.any(
      (request) =>
          request.eventId == eventId &&
          request.requesterId == userId &&
          request.kind == EventRequestKind.professionalService &&
          request.status != RequestStatus.rejected &&
          request.status != RequestStatus.withdrawn,
    );
    if (duplicate) {
      throw const AppException(
        'You already sent a professional application for this event.',
      );
    }
    final now = DateTime.now();
    final request = EventRequest(
      id: 'request-${_nextId()}',
      eventId: eventId,
      hostId: event.hostId,
      requesterId: userId,
      note: message.trim(),
      groupSize: 1,
      companionNames: const [],
      status: RequestStatus.pending,
      createdAt: now,
      kind: EventRequestKind.professionalService,
      professionalCategory: profile.category,
    );
    _requests.add(request);
    _swipedEventIds.putIfAbsent(userId, () => <String>{}).add(eventId);
    _replaceEvent(
      event.copyWith(requestCount: event.requestCount + 1, updatedAt: now),
    );
    _notifications.add(
      NotificationItem(
        id: 'notification-${_nextId()}',
        userId: event.hostId,
        type: NotificationType.professionalRequest,
        title: '${profile.category.label} application',
        body:
            '${profile.businessName} sent a professional application for ${event.title}.',
        createdAt: now,
        read: false,
        eventId: event.id,
      ),
    );
    await _persistEventIfCreated(eventId);
    return request;
  }

  @override
  Future<void> undoSwipe(String userId, String eventId) async {
    await _ensureHydrated();
    _swipedEventIds[userId]?.remove(eventId);
    _rejectedEventIds[userId]?.remove(eventId);
  }

  @override
  Future<PullupMatch> acceptRequest(String hostId, String requestId) async {
    await _ensureHydrated();
    final request = _requestById(requestId);
    final event = _eventById(request.eventId);
    if (event.hostId != hostId) {
      throw const AppException('Only the host can accept this request.');
    }
    if (request.status != RequestStatus.pending) {
      throw const AppException('This request is no longer pending.');
    }
    final seatsRequired = request.reservedSpots;
    if (event.availableSpots < seatsRequired) {
      throw const AppException('Not enough spots left.');
    }
    final now = DateTime.now();
    final acceptedAttendance = _attendanceForRequest(request);
    final updatedRequest = request.copyWith(
      status: RequestStatus.accepted,
      decidedAt: now,
    );
    _replaceRequest(updatedRequest);
    final remaining = event.availableSpots - seatsRequired;
    final acceptedUserIds = {request.requesterId, ...request.companionUserIds};
    _replaceEvent(
      event.copyWith(
        acceptedParticipantIds: {
          ...event.acceptedParticipantIds,
          ...acceptedUserIds,
        }.toList(),
        waitingParticipantIds: event.waitingParticipantIds
            .where((id) => id != request.requesterId)
            .toList(),
        availableSpots: remaining,
        attendance: event.attendance.addAcceptedGroup(
          men: acceptedAttendance.men,
          women: acceptedAttendance.women,
          other: acceptedAttendance.other,
        ),
        status: seatsRequired > 0 && remaining == 0
            ? EventStatus.full
            : event.status,
        matchCount: event.matchCount + 1,
        updatedAt: now,
      ),
    );

    final memberIds = {hostId, ...acceptedUserIds}.toList();
    final conversation = ChatConversation(
      id: 'conversation-${_nextId()}',
      eventId: event.id,
      memberIds: memberIds,
      lastMessagePreview: 'Group chat opened for 12 hours.',
      updatedAt: now,
      unreadByUserIds: acceptedUserIds.toList(),
      isGroup: true,
      expiresAt: now.add(const Duration(hours: 12)),
    );
    _conversations.add(conversation);
    _messages.addAll([
      ChatMessage(
        id: 'message-${_nextId()}',
        conversationId: conversation.id,
        senderId: 'system',
        type: MessageType.system,
        text: request.kind == EventRequestKind.professionalService
            ? '${request.professionalCategory?.label ?? 'Professional'} application accepted for ${event.title}. This chat is available for 12 hours.'
            : 'Group confirmed for ${event.title}. This chat is available for 12 hours.',
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
    for (final acceptedUserId in acceptedUserIds) {
      _notifications.add(
        NotificationItem(
          id: 'notification-${_nextId()}',
          userId: acceptedUserId,
          type: NotificationType.requestAccepted,
          title: 'You are in',
          body:
              '${event.hostPreview.firstName} accepted the group for ${event.title}.',
          createdAt: now,
          read: false,
          eventId: event.id,
          conversationId: conversation.id,
        ),
      );
    }
    await _persistEventIfCreated(event.id);
    return match;
  }

  @override
  Future<EventRequest> rejectRequest(
    String hostId,
    String requestId, {
    String? reason,
  }) async {
    await _ensureHydrated();
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
    await _persistEventIfCreated(event.id);
    return updated;
  }

  @override
  Future<PartyEvent> updateEventAccess(
    String hostId,
    String eventId, {
    required String exactAddress,
    required String accessInstructions,
  }) async {
    await _ensureHydrated();
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
    await _persistEventIfCreated(event.id);
    return updated;
  }

  @override
  Future<ChatMessage> sendMessage(
    String userId,
    String conversationId,
    String text,
  ) async {
    await _ensureHydrated();
    final conversation = _conversationById(conversationId);
    if (!conversation.memberIds.contains(userId)) {
      throw const AppException(
        'You are not allowed to access this conversation.',
      );
    }
    if (conversation.isExpired) {
      throw const AppException(
        'This ephemeral conversation has expired after 12 hours.',
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
    await _ensureHydrated();
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
    await _ensureHydrated();
    _userById(blockedUserId);
    final updated = _updateUser(
      userId,
      (user) => user.copyWith(
        blockedUserIds: {...user.blockedUserIds, blockedUserId}.toList(),
        friendIds: user.friendIds
            .where((friendId) => friendId != blockedUserId)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    );
    final updatedBlocked = _updateUser(
      blockedUserId,
      (user) => user.copyWith(
        friendIds: user.friendIds
            .where((friendId) => friendId != userId)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    );
    await _localStore.saveUser(updated);
    await _localStore.saveUser(updatedBlocked);
    return updated;
  }

  @override
  Future<UserProfile> unblockUser(String userId, String blockedUserId) async {
    await _ensureHydrated();
    final updated = _updateUser(
      userId,
      (user) => user.copyWith(
        blockedUserIds: user.blockedUserIds
            .where((id) => id != blockedUserId)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    );
    await _localStore.saveUser(updated);
    return updated;
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
    await _ensureHydrated();
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

  Future<void> _ensureHydrated() {
    return _hydration ??= _hydrate();
  }

  Future<void> _hydrate() async {
    final persisted = await _localStore.load();
    _credentials = persisted.credentials;
    for (final storedUser in persisted.users) {
      final seedUser = _seedUsersById[storedUser.id];
      final user = storedUser.copyWith(
        city: 'Toulouse',
        approximateLocation: const GeoPointLite(
          latitude: 43.6047,
          longitude: 1.4442,
        ),
        accountType: seedUser?.accountType ?? storedUser.accountType,
        professionalProfile:
            seedUser?.professionalProfile ?? storedUser.professionalProfile,
        isDj: seedUser?.isDj ?? storedUser.isDj,
      );
      final index = _users.indexWhere((item) => item.id == user.id);
      if (index == -1) {
        _users.add(user);
      } else {
        _users[index] = user;
      }
      await _localStore.saveUser(user);
    }
    for (final storedEvent in persisted.events) {
      final seedEvent = _seedEventsById[storedEvent.id];
      final wasAlreadyInToulouse =
          storedEvent.city.trim().toLowerCase() == 'toulouse';
      final event = storedEvent.copyWith(
        city: 'Toulouse',
        areaName:
            seedEvent?.areaName ??
            (wasAlreadyInToulouse ? storedEvent.areaName : 'Centre-ville'),
        approximateGeoPoint:
            seedEvent?.approximateGeoPoint ??
            (wasAlreadyInToulouse
                ? storedEvent.approximateGeoPoint
                : const GeoPointLite(latitude: 43.6047, longitude: 1.4442)),
        exactAddress:
            seedEvent?.exactAddress ??
            (wasAlreadyInToulouse
                ? storedEvent.exactAddress
                : 'Private address to confirm, Toulouse'),
        hostPreview: seedEvent?.hostPreview ?? storedEvent.hostPreview,
        organizerType: seedEvent?.organizerType ?? storedEvent.organizerType,
        guestInteractionMode:
            seedEvent?.guestInteractionMode ?? storedEvent.guestInteractionMode,
        professionalNeeds:
            seedEvent?.professionalNeeds ?? storedEvent.professionalNeeds,
        attendance: seedEvent?.attendance ?? storedEvent.attendance,
        entryFeeCents: seedEvent?.entryFeeCents ?? storedEvent.entryFeeCents,
        foodPolicy: seedEvent?.foodPolicy ?? storedEvent.foodPolicy,
        illegalSubstancesProhibited: true,
      );
      final index = _events.indexWhere((item) => item.id == event.id);
      if (index == -1) {
        _events.add(event);
      } else {
        _events[index] = event;
      }
      _createdEventIds.add(event.id);
      await _localStore.saveEvent(event);
    }
  }

  UserProfile? _findUser(String id) {
    for (final user in _users) {
      if (user.id == id) return user;
    }
    return null;
  }

  Future<void> _persistEventIfCreated(String eventId) async {
    if (!_createdEventIds.contains(eventId)) return;
    await _localStore.saveEvent(_eventById(eventId));
  }

  ({int men, int women, int other}) _attendanceForRequest(
    EventRequest request,
  ) {
    if (request.kind == EventRequestKind.professionalService) {
      return (men: 0, women: 0, other: 0);
    }
    var men = request.guestMenCount;
    var women = request.guestWomenCount;
    var other = request.companionNames.length;
    for (final userId in {request.requesterId, ...request.companionUserIds}) {
      switch (_userById(userId).gender) {
        case Gender.man:
          men++;
        case Gender.woman:
          women++;
        case Gender.nonBinary:
        case Gender.other:
        case Gender.preferNotToSay:
          other++;
      }
    }
    final unclassified = request.groupSize - men - women - other;
    if (unclassified > 0) other += unclassified;
    return (men: men, women: women, other: other);
  }
}
