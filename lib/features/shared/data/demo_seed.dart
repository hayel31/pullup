import '../../../models/chat.dart';
import '../../../models/attendance_breakdown.dart';
import '../../../models/dj.dart';
import '../../../models/enums.dart';
import '../../../models/event_request.dart';
import '../../../models/geo_point_lite.dart';
import '../../../models/notification_item.dart';
import '../../../models/party_event.dart';
import '../../../models/pullup_match.dart';
import '../../../models/professional_profile.dart';
import '../../../models/user_profile.dart';
import '../domain/pullup_repository.dart';

class DemoSeed {
  const DemoSeed._();

  static const _eventPhotoPaths = <String, List<String>>{
    'event-001': ['assets/demo/events/rooftop-night.jpg'],
    'event-002': ['assets/demo/events/villa-pool-party.jpg'],
    'event-003': ['assets/demo/events/apartment-pregame.jpg'],
    'event-004': ['assets/demo/events/yacht-sunset.jpg'],
    'event-005': ['assets/demo/events/student-apartment.jpg'],
    'event-006': ['assets/demo/events/private-dj-set.jpg'],
    'event-007': ['assets/demo/events/birthday-suite.jpg'],
    'event-008': ['assets/demo/events/pigalle-after.jpg'],
    'event-009': ['assets/demo/events/private-dj-set.jpg'],
    'event-010': ['assets/demo/events/villa-pool-party.jpg'],
  };

  static PullupSnapshot build() {
    final now = DateTime.now();
    final users = <UserProfile>[
      _user(
        'user-001',
        'Maya',
        'Rossi',
        'maya@pullup.demo',
        'Toulouse',
        1999,
        true,
        false,
        false,
        6,
      ),
      _user(
        'host-001',
        'Leo',
        'Carter',
        'leo@pullup.demo',
        'Toulouse',
        1996,
        true,
        false,
        true,
        14,
      ),
      _user(
        'host-002',
        'Jade',
        'Morgan',
        'jade@pullup.demo',
        'Toulouse',
        1998,
        true,
        false,
        true,
        8,
      ),
      _user(
        'host-003',
        'Noah',
        'Bennett',
        'noah@pullup.demo',
        'Toulouse',
        1994,
        true,
        false,
        true,
        11,
      ),
      _user(
        'dj-001',
        'Nina',
        'Volt',
        'nina@pullup.demo',
        'Toulouse',
        1995,
        true,
        true,
        true,
        5,
        professionalProfile: _ninaProfessionalProfile(),
      ),
      _user(
        'dj-002',
        'Sami',
        'Wave',
        'sami@pullup.demo',
        'Toulouse',
        1997,
        true,
        true,
        false,
        2,
      ),
      _user(
        'dj-003',
        'Iris',
        'K',
        'iris@pullup.demo',
        'Toulouse',
        1993,
        true,
        true,
        false,
        4,
      ),
      _user(
        'user-002',
        'Enzo',
        'Lima',
        'enzo@pullup.demo',
        'Toulouse',
        2000,
        true,
        false,
        false,
        2,
      ),
      _user(
        'user-003',
        'Lina',
        'Park',
        'lina@pullup.demo',
        'Toulouse',
        2001,
        true,
        false,
        false,
        1,
      ),
      _user(
        'user-004',
        'Adam',
        'Cole',
        'adam@pullup.demo',
        'Toulouse',
        1998,
        true,
        false,
        false,
        3,
      ),
      _user(
        'user-005',
        'Clara',
        'Stone',
        'clara@pullup.demo',
        'Toulouse',
        1999,
        true,
        false,
        false,
        4,
      ),
      _user(
        'user-006',
        'Rayan',
        'Diaz',
        'rayan@pullup.demo',
        'Toulouse',
        1997,
        true,
        false,
        false,
        5,
      ),
      _user(
        'pro-bar-001',
        'Le Halo',
        'Toulouse',
        'halo@pullup.demo',
        'Toulouse',
        1992,
        true,
        false,
        true,
        18,
        professionalProfile: _barProfessionalProfile(),
      ),
    ];
    _connectFriends(users, 'user-001', 'user-002');
    _connectFriends(users, 'user-001', 'user-003');
    _connectFriends(users, 'user-001', 'user-004');
    _connectFriends(users, 'user-002', 'user-003');
    _connectFriends(users, 'host-001', 'user-005');
    _connectFriends(users, 'host-001', 'user-006');

    final host1 = users.firstWhere((user) => user.id == 'host-001');
    final host2 = users.firstWhere((user) => user.id == 'host-002');
    final host3 = users.firstWhere((user) => user.id == 'host-003');
    final host4 = users.firstWhere((user) => user.id == 'dj-001');
    final venueHost = users.firstWhere((user) => user.id == 'pro-bar-001');
    final events = <PartyEvent>[
      _event(
        id: 'event-001',
        host: host1,
        title: 'Rooftop above Capitole',
        category: EventCategory.rooftop,
        area: 'Capitole',
        city: 'Toulouse',
        start: now.add(const Duration(minutes: 35)),
        end: now.add(const Duration(hours: 5)),
        spots: 3,
        max: 20,
        imageId: 1027,
        tags: [
          EventTag.outdoor,
          EventTag.dj,
          EventTag.lastMinute,
          EventTag.dancing,
          EventTag.groupsWelcome,
        ],
        genres: ['House', 'Afro', 'Commercial'],
        boosted: true,
        exactAddress: '8 Rue du Taur, 31000 Toulouse',
        professionalNeeds: const [ProfessionalCategory.photographer],
      ),
      _event(
        id: 'event-002',
        host: host2,
        title: 'Villa pool after in Compans',
        category: EventCategory.poolParty,
        area: 'Compans-Caffarelli',
        city: 'Toulouse',
        start: now.add(const Duration(hours: 2)),
        end: now.add(const Duration(hours: 7)),
        spots: 6,
        max: 24,
        imageId: 1011,
        tags: [
          EventTag.pool,
          EventTag.byob,
          EventTag.groupsWelcome,
          EventTag.musicLoud,
        ],
        genres: ['R&B', 'Reggaeton', 'Rap'],
        boosted: false,
        exactAddress: '12 Esplanade Compans Caffarelli, 31000 Toulouse',
        professionalNeeds: const [
          ProfessionalCategory.bartender,
          ProfessionalCategory.security,
        ],
      ),
      _event(
        id: 'event-003',
        host: host1,
        title: 'Pre-game in Les Carmes',
        category: EventCategory.preGame,
        area: 'Les Carmes',
        city: 'Toulouse',
        start: now.add(const Duration(hours: 1)),
        end: now.add(const Duration(hours: 3)),
        spots: 2,
        max: 10,
        imageId: 1041,
        tags: [EventTag.byob, EventTag.indoor, EventTag.invitationOnly],
        genres: ['Hip-hop', 'Rap', 'Commercial'],
        boosted: false,
        exactAddress: '6 Rue des Filatiers, 31000 Toulouse',
      ),
      _event(
        id: 'event-004',
        host: host3,
        title: 'Canal sunset boat party',
        category: EventCategory.boatParty,
        area: 'Canal du Midi',
        city: 'Toulouse',
        start: now.add(const Duration(days: 1, hours: 2)),
        end: now.add(const Duration(days: 1, hours: 7)),
        spots: 8,
        max: 32,
        imageId: 1050,
        tags: [
          EventTag.outdoor,
          EventTag.photosAllowed,
          EventTag.couplesWelcome,
        ],
        genres: ['House', 'Techno'],
        boosted: true,
        exactAddress: "Port de l'Embouchure, 31200 Toulouse",
        professionalNeeds: const [ProfessionalCategory.dj],
      ),
      _event(
        id: 'event-005',
        host: host2,
        title: 'Student apartment night in Rangueil',
        category: EventCategory.studentParty,
        area: 'Rangueil',
        city: 'Toulouse',
        start: now.add(const Duration(hours: 4)),
        end: now.add(const Duration(hours: 8)),
        spots: 12,
        max: 26,
        imageId: 1067,
        tags: [EventTag.indoor, EventTag.groupsWelcome, EventTag.byob],
        genres: ['Student nights', 'Commercial', 'Rap'],
        boosted: false,
        exactAddress: '31 Avenue Jules Julien, 31400 Toulouse',
      ),
      _event(
        id: 'event-006',
        host: host1,
        title: 'Private DJ set in Saint-Cyprien',
        category: EventCategory.privateDjSet,
        area: 'Saint-Cyprien',
        city: 'Toulouse',
        start: now.subtract(const Duration(minutes: 20)),
        end: now.add(const Duration(hours: 4)),
        spots: 5,
        max: 18,
        imageId: 1076,
        tags: [EventTag.dj, EventTag.musicLoud, EventTag.invitationOnly],
        genres: ['Techno', 'House'],
        boosted: true,
        exactAddress: '5 Place Olivier, 31300 Toulouse',
        professionalNeeds: const [ProfessionalCategory.videographer],
      ),
      _event(
        id: 'event-007',
        host: host3,
        title: 'Birthday villa in Côte Pavée',
        category: EventCategory.birthday,
        area: 'Côte Pavée',
        city: 'Toulouse',
        start: now.add(const Duration(hours: 5)),
        end: now.add(const Duration(hours: 10)),
        spots: 4,
        max: 16,
        imageId: 1084,
        tags: [
          EventTag.dressCode,
          EventTag.securityPresent,
          EventTag.chillAtmosphere,
        ],
        genres: ['Afro', 'R&B'],
        boosted: false,
        exactAddress: '73 Avenue Jean Rieux, 31500 Toulouse',
        professionalNeeds: const [ProfessionalCategory.photographer],
      ),
      _event(
        id: 'event-008',
        host: venueHost,
        title: 'After hours at Le Halo',
        category: EventCategory.after,
        area: 'Jean-Jaurès',
        city: 'Toulouse',
        start: now.add(const Duration(minutes: 10)),
        end: now.add(const Duration(hours: 6)),
        spots: 1,
        max: 12,
        imageId: 1080,
        tags: [EventTag.lastMinute, EventTag.indoor, EventTag.noPhotos],
        genres: ['Techno', 'Afro', 'House'],
        boosted: false,
        exactAddress: '18 Allées Jean Jaurès, 31000 Toulouse',
        professionalNeeds: const [ProfessionalCategory.dj],
      ),
      _event(
        id: 'event-009',
        host: host4,
        title: 'Nina Volt neon session',
        category: EventCategory.privateDjSet,
        area: 'Saint-Aubin',
        city: 'Toulouse',
        start: now.add(const Duration(hours: 3)),
        end: now.add(const Duration(hours: 8)),
        spots: 7,
        max: 22,
        imageId: 1062,
        tags: [
          EventTag.dj,
          EventTag.indoor,
          EventTag.dancing,
          EventTag.invitationOnly,
        ],
        genres: ['Techno', 'House', 'Electro'],
        boosted: true,
        exactAddress: '26 Rue de la Colombette, 31000 Toulouse',
        professionalNeeds: const [ProfessionalCategory.photographer],
      ),
      _event(
        id: 'event-010',
        host: venueHost,
        title: 'Le Halo rooftop pool night',
        category: EventCategory.villaParty,
        area: 'Les Carmes',
        city: 'Toulouse',
        start: now.add(const Duration(hours: 1, minutes: 30)),
        end: now.add(const Duration(hours: 7)),
        spots: 9,
        max: 28,
        imageId: 1091,
        tags: [
          EventTag.pool,
          EventTag.outdoor,
          EventTag.dj,
          EventTag.groupsWelcome,
          EventTag.lastMinute,
        ],
        genres: ['House', 'Afro', 'R&B'],
        boosted: true,
        exactAddress: '12 Rue Pharaon, 31000 Toulouse',
        professionalNeeds: const [
          ProfessionalCategory.photographer,
          ProfessionalCategory.bartender,
        ],
      ),
    ];

    final pending = EventRequest(
      id: 'request-001',
      eventId: 'event-001',
      hostId: 'host-001',
      requesterId: 'user-003',
      note: 'I can bring drinks and come with one friend.',
      groupSize: 2,
      companionNames: ['Ana'],
      status: RequestStatus.pending,
      createdAt: now.subtract(const Duration(minutes: 12)),
    );
    final pendingSolo = EventRequest(
      id: 'request-003',
      eventId: 'event-001',
      hostId: 'host-001',
      requesterId: 'user-004',
      note: 'I am in Toulouse tonight and can arrive before the DJ starts.',
      groupSize: 1,
      companionNames: const [],
      status: RequestStatus.pending,
      createdAt: now.subtract(const Duration(minutes: 26)),
    );
    final pendingGroup = EventRequest(
      id: 'request-004',
      eventId: 'event-001',
      hostId: 'host-001',
      requesterId: 'user-006',
      note: 'Three of us, respectful and happy to bring ice and soft drinks.',
      groupSize: 3,
      companionNames: const [],
      guestMenCount: 1,
      guestWomenCount: 1,
      status: RequestStatus.pending,
      createdAt: now.subtract(const Duration(minutes: 41)),
    );
    final acceptedRooftop = EventRequest(
      id: 'request-005',
      eventId: 'event-001',
      hostId: 'host-001',
      requesterId: 'user-002',
      note: 'Coming solo, I already know the Capitole area.',
      groupSize: 1,
      companionNames: const [],
      status: RequestStatus.accepted,
      createdAt: now.subtract(const Duration(hours: 2)),
      decidedAt: now.subtract(const Duration(hours: 1, minutes: 35)),
    );
    final declinedRooftop = EventRequest(
      id: 'request-006',
      eventId: 'event-001',
      hostId: 'host-001',
      requesterId: 'user-005',
      note: 'We would be a group of four coming from Saint-Cyprien.',
      groupSize: 4,
      companionNames: const ['Lou', 'Sarah', 'Tom'],
      status: RequestStatus.rejected,
      createdAt: now.subtract(const Duration(hours: 3)),
      decidedAt: now.subtract(const Duration(hours: 2, minutes: 20)),
      decisionReason: 'Guest list balance',
    );
    final accepted = EventRequest(
      id: 'request-002',
      eventId: 'event-006',
      hostId: 'host-001',
      requesterId: 'user-001',
      note: 'Enzo and I are near Saint-Cyprien and can pull up fast.',
      groupSize: 2,
      companionNames: const [],
      companionUserIds: const ['user-002'],
      status: RequestStatus.accepted,
      createdAt: now.subtract(const Duration(hours: 1)),
      decidedAt: now.subtract(const Duration(minutes: 42)),
    );
    final loftIndex = events.indexWhere((event) => event.id == 'event-006');
    events[loftIndex] = events[loftIndex].copyWith(
      acceptedParticipantIds: const ['user-001', 'user-002'],
      availableSpots: events[loftIndex].availableSpots - 2,
      attendance: events[loftIndex].attendance.addAcceptedGroup(
        men: 1,
        women: 1,
        other: 0,
      ),
    );

    final conversation = ChatConversation(
      id: 'conversation-001',
      eventId: 'event-006',
      memberIds: const ['user-001', 'user-002', 'host-001'],
      lastMessagePreview: 'Enzo: We are on our way.',
      updatedAt: now.subtract(const Duration(minutes: 40)),
      unreadByUserIds: const ['user-001'],
      isGroup: true,
      expiresAt: now.add(const Duration(hours: 11, minutes: 20)),
    );
    final rooftopConversation = ChatConversation(
      id: 'conversation-002',
      eventId: 'event-001',
      memberIds: const ['user-002', 'host-001'],
      lastMessagePreview: 'Access unlocked for Rooftop above Capitole.',
      updatedAt: now.subtract(const Duration(hours: 1, minutes: 34)),
      unreadByUserIds: const ['user-002'],
      isGroup: true,
      expiresAt: now.add(const Duration(hours: 10, minutes: 25)),
    );
    final messages = [
      ChatMessage(
        id: 'message-001',
        conversationId: conversation.id,
        senderId: 'system',
        type: MessageType.system,
        text: 'Match created for Private DJ set in Saint-Cyprien.',
        createdAt: now.subtract(const Duration(minutes: 42)),
        readByUserIds: const ['host-001'],
      ),
      ChatMessage(
        id: 'message-005',
        conversationId: conversation.id,
        senderId: 'user-002',
        type: MessageType.text,
        text: 'We are on our way.',
        createdAt: now.subtract(const Duration(minutes: 39)),
        readByUserIds: const ['user-002'],
      ),
      ChatMessage(
        id: 'message-002',
        conversationId: conversation.id,
        senderId: 'system',
        type: MessageType.system,
        text: 'Exact address unlocked. See you soon.',
        createdAt: now.subtract(const Duration(minutes: 41)),
        readByUserIds: const ['host-001'],
      ),
      ChatMessage(
        id: 'message-003',
        conversationId: conversation.id,
        senderId: 'host-001',
        type: MessageType.text,
        text: 'Use the side entrance and say Leo at the door.',
        createdAt: now.subtract(const Duration(minutes: 40)),
        readByUserIds: const ['host-001'],
      ),
      ChatMessage(
        id: 'message-004',
        conversationId: rooftopConversation.id,
        senderId: 'system',
        type: MessageType.system,
        text: 'Access unlocked for Rooftop above Capitole.',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 34)),
        readByUserIds: const ['host-001'],
      ),
    ];

    final djs = [
      _dj('dj-profile-001', users[4], 'Nina Volt', true, [
        'House',
        'Techno',
        'Afro',
      ]),
      _dj('dj-profile-002', users[5], 'Sami Wave', false, [
        'Rap',
        'R&B',
        'Reggaeton',
      ]),
      _dj('dj-profile-003', users[6], 'Iris K', false, [
        'House',
        'Commercial',
        'Afro',
      ]),
    ];

    return PullupSnapshot(
      users: users,
      events: events,
      requests: [
        pending,
        pendingSolo,
        pendingGroup,
        acceptedRooftop,
        declinedRooftop,
        accepted,
      ],
      matches: [
        PullupMatch(
          id: 'match-002',
          userId: 'user-002',
          hostId: 'host-001',
          eventId: 'event-001',
          conversationId: rooftopConversation.id,
          status: MatchStatus.active,
          createdAt: now.subtract(const Duration(hours: 1, minutes: 35)),
          isNew: false,
        ),
        PullupMatch(
          id: 'match-001',
          userId: 'user-001',
          hostId: 'host-001',
          eventId: 'event-006',
          conversationId: conversation.id,
          status: MatchStatus.active,
          createdAt: now.subtract(const Duration(minutes: 42)),
          isNew: true,
        ),
      ],
      conversations: [conversation, rooftopConversation],
      messages: messages,
      notifications: [
        NotificationItem(
          id: 'notification-001',
          userId: 'user-001',
          type: NotificationType.requestAccepted,
          title: 'You are in',
          body: 'Leo accepted you for Private DJ set in Saint-Cyprien.',
          createdAt: now.subtract(const Duration(minutes: 42)),
          read: false,
          eventId: 'event-006',
          conversationId: 'conversation-001',
        ),
        NotificationItem(
          id: 'notification-002',
          userId: 'host-001',
          type: NotificationType.requestReceived,
          title: 'New request',
          body: 'Lina wants to join Rooftop above Capitole.',
          createdAt: now.subtract(const Duration(minutes: 12)),
          read: false,
          eventId: 'event-001',
        ),
      ],
      reports: const [],
      djProfiles: djs,
      swipedEventIds: const {},
      rejectedEventIds: const {},
    );
  }

  static UserProfile _user(
    String id,
    String firstName,
    String lastName,
    String email,
    String city,
    int birthYear,
    bool onboarded,
    bool isDj,
    bool isHost,
    int hostedCount, {
    ProfessionalProfile? professionalProfile,
  }) {
    final now = DateTime.now();
    final photoSeed = id.hashCode.abs() % 80 + 10;
    return UserProfile(
      id: id,
      email: email,
      displayName: firstName,
      firstName: firstName,
      lastName: lastName,
      birthDate: DateTime(birthYear, 4, 12),
      gender: _genderForUser(id),
      bio: 'Night plans, good music, respectful energy.',
      city: 'Toulouse',
      approximateLocation: const GeoPointLite(
        latitude: 43.6047,
        longitude: 1.4442,
      ),
      profilePhotos: [
        'https://picsum.photos/seed/pullup-user-$photoSeed/900/1200',
        'https://picsum.photos/seed/pullup-user-${photoSeed + 1}/900/1200',
      ],
      mainPhotoUrl:
          'https://picsum.photos/seed/pullup-user-$photoSeed/900/1200',
      interests: const ['Rooftops', 'Afters', 'Cocktails'],
      musicPreferences: const ['House', 'Afro', 'Rap'],
      languages: const ['French', 'English'],
      occupation: 'Creative',
      instagramHandle: '@pullup.demo',
      verificationStatus: VerificationStatus.email,
      phoneVerified: hostedCount > 2,
      selfieVerified: hostedCount > 4,
      identityVerified: hostedCount > 7,
      isPremium: id == 'user-001',
      isDj: isDj,
      isHost: isHost,
      hostRating: 4.7,
      hostedEventCount: hostedCount,
      guestAttendanceCount: hostedCount + 3,
      reportCount: 0,
      blockedUserIds: const [],
      createdAt: now.subtract(const Duration(days: 120)),
      updatedAt: now,
      lastActiveAt: now.subtract(const Duration(minutes: 9)),
      accountStatus: AccountStatus.active,
      onboardingCompleted: onboarded,
      accountType: professionalProfile == null
          ? AccountType.personal
          : AccountType.professional,
      professionalProfile: professionalProfile,
    );
  }

  static void _connectFriends(
    List<UserProfile> users,
    String firstId,
    String secondId,
  ) {
    final firstIndex = users.indexWhere((user) => user.id == firstId);
    final secondIndex = users.indexWhere((user) => user.id == secondId);
    if (firstIndex == -1 || secondIndex == -1) return;
    users[firstIndex] = users[firstIndex].copyWith(
      friendIds: {...users[firstIndex].friendIds, secondId}.toList(),
    );
    users[secondIndex] = users[secondIndex].copyWith(
      friendIds: {...users[secondIndex].friendIds, firstId}.toList(),
    );
  }

  static PartyEvent _event({
    required String id,
    required UserProfile host,
    required String title,
    required EventCategory category,
    required String area,
    required String city,
    required DateTime start,
    required DateTime end,
    required int spots,
    required int max,
    required int imageId,
    required List<EventTag> tags,
    required List<String> genres,
    required bool boosted,
    required String exactAddress,
    List<ProfessionalCategory> professionalNeeds = const [],
  }) {
    final now = DateTime.now();
    final photoPaths = _eventPhotoPaths[id]!;
    final point = GeoPointLite(
      latitude: 43.6047 + imageId % 7 / 1000,
      longitude: 1.4442 + imageId % 9 / 1000,
    );
    final professional = host.professionalProfile;
    final occupied = (max - spots).clamp(0, max);
    final otherCount = occupied >= 10 ? 1 : 0;
    final genderedCount = occupied - otherCount;
    final womenCount = (genderedCount * (0.46 + (imageId % 3) * 0.04))
        .round()
        .clamp(0, genderedCount);
    final menCount = genderedCount - womenCount;
    final alcoholPolicy = _alcoholPolicyFor(id, tags);
    final foodPolicy = _foodPolicyFor(id);
    final entryFeeCents = _entryFeeFor(id);
    final organizerType = professional == null
        ? EventOrganizerType.privateHost
        : professional.isVenue
        ? EventOrganizerType.venue
        : EventOrganizerType.professional;
    return PartyEvent(
      id: id,
      hostId: host.id,
      hostPreview: HostPreview(
        id: host.id,
        firstName: host.firstName,
        photoUrl: host.mainPhotoUrl ?? host.profilePhotos.first,
        badges: host.badges,
        hostedEventCount: host.hostedEventCount,
        accountType: host.accountType,
        professionalCategory: professional?.category,
        businessName: professional?.businessName,
      ),
      title: title,
      description:
          'A private night plan with curated music, clear rules, and a respectful guest list.',
      category: category,
      coverPhotoUrl: photoPaths.first,
      photoUrls: photoPaths,
      city: city,
      areaName: area,
      approximateGeoPoint: point,
      exactAddress: exactAddress,
      accessInstructions:
          'Address appears only after host approval. Ring the bell once.',
      startDateTime: start,
      endDateTime: end,
      timezone: 'Europe/Paris',
      ageRequirement: 18,
      maxParticipants: max,
      availableSpots: spots,
      acceptedParticipantIds: id == 'event-006'
          ? const ['user-001']
          : id == 'event-001'
          ? const ['user-002']
          : const [],
      waitingParticipantIds: id == 'event-001'
          ? const ['user-003', 'user-004', 'user-006']
          : const [],
      rejectedParticipantIds: id == 'event-001' ? const ['user-005'] : const [],
      eventTags: tags,
      musicGenres: genres,
      dressCode: tags.contains(EventTag.dressCode)
          ? 'All black, clean sneakers.'
          : 'Night casual.',
      contributionText: _customContributionFor(id),
      houseRules:
          'Respect the address, no harassment, no public address sharing.',
      alcoholPolicy: alcoholPolicy,
      smokingPolicy: tags.contains(EventTag.smokeFriendly)
          ? SmokingPolicy.smokeFriendly
          : SmokingPolicy.outdoorOnly,
      visibility: EventVisibility.public,
      status: start.isBefore(now) && end.isAfter(now)
          ? EventStatus.ongoing
          : EventStatus.published,
      approvalMode: ApprovalMode.manual,
      allowsGroups: tags.contains(EventTag.groupsWelcome),
      maxGroupSize: tags.contains(EventTag.groupsWelcome) ? 4 : 1,
      isBoosted: boosted,
      boostEndDate: boosted ? now.add(const Duration(hours: 6)) : null,
      likeCount: imageId % 23 + 8,
      requestCount: id == 'event-001' ? 5 : imageId % 9,
      matchCount: id == 'event-001' || id == 'event-006' ? 1 : imageId % 5,
      createdAt: now.subtract(Duration(hours: imageId % 12 + 1)),
      updatedAt: now,
      expiresAt: end.add(const Duration(hours: 2)),
      organizerType: organizerType,
      guestInteractionMode: organizerType == EventOrganizerType.venue
          ? GuestInteractionMode.openInterest
          : GuestInteractionMode.approvalRequest,
      professionalNeeds: professionalNeeds,
      attendance: AttendanceBreakdown.initial(
        men: menCount,
        women: womenCount,
        other: otherCount,
      ),
      entryFeeCents: entryFeeCents,
      foodPolicy: foodPolicy,
      illegalSubstancesProhibited: true,
    );
  }

  static Gender _genderForUser(String id) => switch (id) {
    'user-001' ||
    'host-002' ||
    'dj-001' ||
    'dj-003' ||
    'user-003' ||
    'user-005' => Gender.woman,
    'host-001' ||
    'host-003' ||
    'dj-002' ||
    'user-002' ||
    'user-004' ||
    'user-006' => Gender.man,
    _ => Gender.preferNotToSay,
  };

  static int _entryFeeFor(String eventId) => switch (eventId) {
    'event-002' || 'event-006' || 'event-009' => 1000,
    'event-004' => 1500,
    'event-008' => 500,
    _ => 0,
  };

  static AlcoholPolicy _alcoholPolicyFor(String eventId, List<EventTag> tags) {
    if (tags.contains(EventTag.noAlcohol)) return AlcoholPolicy.notAllowed;
    return switch (eventId) {
      'event-002' ||
      'event-004' ||
      'event-006' ||
      'event-007' ||
      'event-008' ||
      'event-009' => AlcoholPolicy.provided,
      _ => AlcoholPolicy.byob,
    };
  }

  static FoodPolicy _foodPolicyFor(String eventId) => switch (eventId) {
    'event-002' || 'event-007' => FoodPolicy.provided,
    'event-001' || 'event-003' || 'event-005' => FoodPolicy.bringFood,
    _ => FoodPolicy.noneRequired,
  };

  static String? _customContributionFor(String eventId) => switch (eventId) {
    'event-003' => 'Ice and soft drinks appreciated.',
    'event-010' => 'Bring a towel for the pool.',
    _ => null,
  };

  static ProfessionalProfile _ninaProfessionalProfile() {
    return const ProfessionalProfile(
      category: ProfessionalCategory.dj,
      businessName: 'Nina Volt',
      headline: 'Open-format DJ for private nights and rooftops',
      description:
          'House, techno and Afro sets built for late-night crowds and premium private events.',
      services: ['DJ set', 'Music curation', 'Sound check', 'After party'],
      portfolioItems: [
        ProfessionalPortfolioItem(
          id: 'nina-photo-1',
          title: 'Neon private set',
          url: 'assets/demo/events/private-dj-set.jpg',
          type: PortfolioMediaType.image,
        ),
        ProfessionalPortfolioItem(
          id: 'nina-mix-1',
          title: 'Midnight rooftop mix',
          url: 'https://soundcloud.com/ninavolt/midnight-rooftop',
          type: PortfolioMediaType.audio,
        ),
      ],
      completedProjects: [
        'Rooftop closing set - Toulouse',
        'Private fashion afterparty',
        'Villa pool session',
      ],
      establishments: ['Le Halo', 'Studio 31', 'Rooftop Garonne'],
      socialLinks: {
        'Instagram': '@ninavolt',
        'SoundCloud': 'soundcloud.com/ninavolt',
        'Spotify': 'open.spotify.com/ninavolt',
      },
      website: 'ninavolt.example',
      travelRadiusKm: 80,
      indicativeRate: 'From 300 EUR',
      availability: 'Thursday to Sunday nights',
      yearsExperience: 6,
      isVerified: true,
    );
  }

  static ProfessionalProfile _barProfessionalProfile() {
    return const ProfessionalProfile(
      category: ProfessionalCategory.bar,
      businessName: 'Le Halo Toulouse',
      headline: 'Cocktail bar, DJ booth and late-night rooftop',
      description:
          'A fictional Toulouse venue for testing public professional events, open entry and service recruitment.',
      services: ['Cocktail bar', 'Rooftop', 'DJ booth', 'Private booking'],
      portfolioItems: [
        ProfessionalPortfolioItem(
          id: 'halo-photo-1',
          title: 'Rooftop night',
          url: 'assets/demo/events/rooftop-night.jpg',
          type: PortfolioMediaType.image,
        ),
        ProfessionalPortfolioItem(
          id: 'halo-photo-2',
          title: 'Pool edition',
          url: 'assets/demo/events/villa-pool-party.jpg',
          type: PortfolioMediaType.image,
        ),
        ProfessionalPortfolioItem(
          id: 'halo-video-1',
          title: 'Venue showreel',
          url: 'https://video.example/le-halo-showreel',
          type: PortfolioMediaType.video,
        ),
      ],
      completedProjects: [
        'Halo opening weekend',
        'Garonne sunset sessions',
        'Toulouse student closing party',
      ],
      establishments: ['Le Halo Toulouse'],
      socialLinks: {
        'Instagram': '@lehalotoulouse',
        'TikTok': '@lehalotoulouse',
      },
      website: 'lehalo.example',
      travelRadiusKm: 10,
      indicativeRate: 'Venue booking on request',
      availability: 'Open Wednesday to Sunday',
      yearsExperience: 8,
      isVerified: true,
    );
  }

  static DjProfile _dj(
    String id,
    UserProfile user,
    String stageName,
    bool verified,
    List<String> genres,
  ) {
    return DjProfile(
      id: id,
      userId: user.id,
      stageName: stageName,
      bio:
          'Private sets, rooftop energy, clean transitions, flexible night slots.',
      photoUrl: user.mainPhotoUrl ?? user.profilePhotos.first,
      galleryUrls: user.profilePhotos,
      musicGenres: genres,
      city: user.city,
      travelRadiusKm: 40,
      equipment: const ['Controller', 'USB', 'Headphones'],
      availability: 'Tonight and weekends',
      indicativeRate: 'From 250 EUR',
      instagram: user.instagramHandle,
      soundCloud:
          'soundcloud.com/${stageName.toLowerCase().replaceAll(' ', '')}',
      spotify: null,
      mixcloud: null,
      isVerified: verified,
    );
  }
}
