import '../core/utils/time_utils.dart';
import 'enums.dart';
import 'geo_point_lite.dart';

class HostPreview {
  const HostPreview({
    required this.id,
    required this.firstName,
    required this.photoUrl,
    required this.badges,
    required this.hostedEventCount,
  });

  final String id;
  final String firstName;
  final String photoUrl;
  final List<VerificationBadge> badges;
  final int hostedEventCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'photoUrl': photoUrl,
    'badges': badges.map((badge) => badge.name).toList(),
    'hostedEventCount': hostedEventCount,
  };

  factory HostPreview.fromJson(Map<String, dynamic> json) {
    return HostPreview(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      photoUrl: json['photoUrl'] as String,
      badges: (json['badges'] as List? ?? const [])
          .map(
            (name) => _enumValue(
              VerificationBadge.values,
              name,
              VerificationBadge.emailVerified,
            ),
          )
          .toList(),
      hostedEventCount: json['hostedEventCount'] as int? ?? 0,
    );
  }
}

class PartyEvent {
  const PartyEvent({
    required this.id,
    required this.hostId,
    required this.hostPreview,
    required this.title,
    required this.description,
    required this.category,
    required this.coverPhotoUrl,
    required this.photoUrls,
    required this.city,
    required this.areaName,
    required this.approximateGeoPoint,
    required this.startDateTime,
    required this.endDateTime,
    required this.timezone,
    required this.ageRequirement,
    required this.maxParticipants,
    required this.availableSpots,
    required this.acceptedParticipantIds,
    required this.waitingParticipantIds,
    required this.rejectedParticipantIds,
    required this.eventTags,
    required this.musicGenres,
    required this.alcoholPolicy,
    required this.smokingPolicy,
    required this.visibility,
    required this.status,
    required this.approvalMode,
    required this.allowsGroups,
    required this.maxGroupSize,
    required this.isBoosted,
    required this.likeCount,
    required this.requestCount,
    required this.matchCount,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    this.exactAddress,
    this.accessInstructions,
    this.dressCode,
    this.contributionText,
    this.houseRules,
    this.boostEndDate,
  });

  final String id;
  final String hostId;
  final HostPreview hostPreview;
  final String title;
  final String description;
  final EventCategory category;
  final String coverPhotoUrl;
  final List<String> photoUrls;
  final String city;
  final String areaName;
  final GeoPointLite approximateGeoPoint;
  final String? exactAddress;
  final String? accessInstructions;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String timezone;
  final int ageRequirement;
  final int maxParticipants;
  final int availableSpots;
  final List<String> acceptedParticipantIds;
  final List<String> waitingParticipantIds;
  final List<String> rejectedParticipantIds;
  final List<EventTag> eventTags;
  final List<String> musicGenres;
  final String? dressCode;
  final String? contributionText;
  final String? houseRules;
  final AlcoholPolicy alcoholPolicy;
  final SmokingPolicy smokingPolicy;
  final EventVisibility visibility;
  final EventStatus status;
  final ApprovalMode approvalMode;
  final bool allowsGroups;
  final int maxGroupSize;
  final bool isBoosted;
  final DateTime? boostEndDate;
  final int likeCount;
  final int requestCount;
  final int matchCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;

  bool get isPublished =>
      status == EventStatus.published || status == EventStatus.ongoing;
  bool get isExpired => expiresAt.isBefore(DateTime.now());
  bool get hasSpots => availableSpots > 0;
  bool get isFewSpotsLeft => availableSpots <= 3 && availableSpots > 0;
  bool get isLastMinute => eventTags.contains(EventTag.lastMinute);
  bool get isStartingSoon {
    final diff = startDateTime.difference(DateTime.now());
    return !isOngoing && diff.inMinutes >= 0 && diff.inHours < 3;
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  bool get isTonight {
    final now = DateTime.now();
    return startDateTime.year == now.year &&
        startDateTime.month == now.month &&
        startDateTime.day == now.day;
  }

  String get timeLabel => TimeUtils.eventWindow(startDateTime, endDateTime);

  bool canRevealAddressTo(String userId) {
    return hostId == userId || acceptedParticipantIds.contains(userId);
  }

  PartyEvent copyWith({
    String? id,
    String? hostId,
    HostPreview? hostPreview,
    String? title,
    String? description,
    EventCategory? category,
    String? coverPhotoUrl,
    List<String>? photoUrls,
    String? city,
    String? areaName,
    GeoPointLite? approximateGeoPoint,
    String? exactAddress,
    String? accessInstructions,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? timezone,
    int? ageRequirement,
    int? maxParticipants,
    int? availableSpots,
    List<String>? acceptedParticipantIds,
    List<String>? waitingParticipantIds,
    List<String>? rejectedParticipantIds,
    List<EventTag>? eventTags,
    List<String>? musicGenres,
    String? dressCode,
    String? contributionText,
    String? houseRules,
    AlcoholPolicy? alcoholPolicy,
    SmokingPolicy? smokingPolicy,
    EventVisibility? visibility,
    EventStatus? status,
    ApprovalMode? approvalMode,
    bool? allowsGroups,
    int? maxGroupSize,
    bool? isBoosted,
    DateTime? boostEndDate,
    int? likeCount,
    int? requestCount,
    int? matchCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return PartyEvent(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostPreview: hostPreview ?? this.hostPreview,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      city: city ?? this.city,
      areaName: areaName ?? this.areaName,
      approximateGeoPoint: approximateGeoPoint ?? this.approximateGeoPoint,
      exactAddress: exactAddress ?? this.exactAddress,
      accessInstructions: accessInstructions ?? this.accessInstructions,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      timezone: timezone ?? this.timezone,
      ageRequirement: ageRequirement ?? this.ageRequirement,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      availableSpots: availableSpots ?? this.availableSpots,
      acceptedParticipantIds:
          acceptedParticipantIds ?? this.acceptedParticipantIds,
      waitingParticipantIds:
          waitingParticipantIds ?? this.waitingParticipantIds,
      rejectedParticipantIds:
          rejectedParticipantIds ?? this.rejectedParticipantIds,
      eventTags: eventTags ?? this.eventTags,
      musicGenres: musicGenres ?? this.musicGenres,
      dressCode: dressCode ?? this.dressCode,
      contributionText: contributionText ?? this.contributionText,
      houseRules: houseRules ?? this.houseRules,
      alcoholPolicy: alcoholPolicy ?? this.alcoholPolicy,
      smokingPolicy: smokingPolicy ?? this.smokingPolicy,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      approvalMode: approvalMode ?? this.approvalMode,
      allowsGroups: allowsGroups ?? this.allowsGroups,
      maxGroupSize: maxGroupSize ?? this.maxGroupSize,
      isBoosted: isBoosted ?? this.isBoosted,
      boostEndDate: boostEndDate ?? this.boostEndDate,
      likeCount: likeCount ?? this.likeCount,
      requestCount: requestCount ?? this.requestCount,
      matchCount: matchCount ?? this.matchCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson({bool includePrivateAddress = false}) => {
    'id': id,
    'hostId': hostId,
    'hostPreview': hostPreview.toJson(),
    'title': title,
    'description': description,
    'category': category.name,
    'coverPhotoUrl': coverPhotoUrl,
    'photoUrls': photoUrls,
    'city': city,
    'areaName': areaName,
    'approximateGeoPoint': approximateGeoPoint.toJson(),
    if (includePrivateAddress) 'exactAddress': exactAddress,
    if (includePrivateAddress) 'accessInstructions': accessInstructions,
    'startDateTime': startDateTime.toIso8601String(),
    'endDateTime': endDateTime.toIso8601String(),
    'timezone': timezone,
    'ageRequirement': ageRequirement,
    'maxParticipants': maxParticipants,
    'availableSpots': availableSpots,
    'acceptedParticipantIds': acceptedParticipantIds,
    'waitingParticipantIds': waitingParticipantIds,
    'rejectedParticipantIds': rejectedParticipantIds,
    'eventTags': eventTags.map((tag) => tag.name).toList(),
    'musicGenres': musicGenres,
    'dressCode': dressCode,
    'contributionText': contributionText,
    'houseRules': houseRules,
    'alcoholPolicy': alcoholPolicy.name,
    'smokingPolicy': smokingPolicy.name,
    'visibility': visibility.name,
    'status': status.name,
    'approvalMode': approvalMode.name,
    'allowsGroups': allowsGroups,
    'maxGroupSize': maxGroupSize,
    'isBoosted': isBoosted,
    'boostEndDate': boostEndDate?.toIso8601String(),
    'likeCount': likeCount,
    'requestCount': requestCount,
    'matchCount': matchCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory PartyEvent.fromJson(Map<String, dynamic> json) {
    return PartyEvent(
      id: json['id'] as String,
      hostId: json['hostId'] as String,
      hostPreview: HostPreview.fromJson(
        Map<String, dynamic>.from(json['hostPreview'] as Map),
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      category: _enumValue(
        EventCategory.values,
        json['category'],
        EventCategory.otherNightPlan,
      ),
      coverPhotoUrl: json['coverPhotoUrl'] as String,
      photoUrls: List<String>.from(json['photoUrls'] as List? ?? const []),
      city: json['city'] as String,
      areaName: json['areaName'] as String,
      approximateGeoPoint: GeoPointLite.fromJson(
        Map<String, dynamic>.from(json['approximateGeoPoint'] as Map),
      ),
      exactAddress: json['exactAddress'] as String?,
      accessInstructions: json['accessInstructions'] as String?,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      timezone: json['timezone'] as String,
      ageRequirement: json['ageRequirement'] as int,
      maxParticipants: json['maxParticipants'] as int,
      availableSpots: json['availableSpots'] as int,
      acceptedParticipantIds: List<String>.from(
        json['acceptedParticipantIds'] as List? ?? const [],
      ),
      waitingParticipantIds: List<String>.from(
        json['waitingParticipantIds'] as List? ?? const [],
      ),
      rejectedParticipantIds: List<String>.from(
        json['rejectedParticipantIds'] as List? ?? const [],
      ),
      eventTags: (json['eventTags'] as List? ?? const [])
          .map((name) => _enumValue(EventTag.values, name, EventTag.lastMinute))
          .toList(),
      musicGenres: List<String>.from(json['musicGenres'] as List? ?? const []),
      dressCode: json['dressCode'] as String?,
      contributionText: json['contributionText'] as String?,
      houseRules: json['houseRules'] as String?,
      alcoholPolicy: _enumValue(
        AlcoholPolicy.values,
        json['alcoholPolicy'],
        AlcoholPolicy.unspecified,
      ),
      smokingPolicy: _enumValue(
        SmokingPolicy.values,
        json['smokingPolicy'],
        SmokingPolicy.unspecified,
      ),
      visibility: _enumValue(
        EventVisibility.values,
        json['visibility'],
        EventVisibility.public,
      ),
      status: _enumValue(
        EventStatus.values,
        json['status'],
        EventStatus.published,
      ),
      approvalMode: _enumValue(
        ApprovalMode.values,
        json['approvalMode'],
        ApprovalMode.manual,
      ),
      allowsGroups: json['allowsGroups'] as bool? ?? false,
      maxGroupSize: json['maxGroupSize'] as int? ?? 1,
      isBoosted: json['isBoosted'] as bool? ?? false,
      boostEndDate: json['boostEndDate'] == null
          ? null
          : DateTime.parse(json['boostEndDate'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      requestCount: json['requestCount'] as int? ?? 0,
      matchCount: json['matchCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

T _enumValue<T extends Enum>(Iterable<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
