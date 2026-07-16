enum Gender { woman, man, nonBinary, other, preferNotToSay }

enum VerificationBadge {
  emailVerified,
  phoneVerified,
  selfieVerified,
  identityVerified,
  verifiedHost,
  verifiedDj,
  superHost,
}

enum VerificationStatus { none, email, phone, selfie, identity }

enum AccountStatus { active, suspended, banned, deleted }

enum EventCategory {
  houseParty,
  poolParty,
  rooftop,
  preGame,
  after,
  boatParty,
  villaParty,
  apartmentParty,
  birthday,
  privateDjSet,
  studentParty,
  otherNightPlan,
}

enum EventTag {
  alcoholAllowed,
  noAlcohol,
  smokeFriendly,
  noSmoking,
  dj,
  pool,
  outdoor,
  indoor,
  bringFood,
  byob,
  dressCode,
  ageRequirement,
  securityPresent,
  invitationOnly,
  couplesWelcome,
  groupsWelcome,
  lastMinute,
  musicLoud,
  chillAtmosphere,
  dancing,
  photosAllowed,
  noPhotos,
  djNeeded,
}

enum AlcoholPolicy { allowed, notAllowed, byob, unspecified }

enum SmokingPolicy { smokeFriendly, noSmoking, outdoorOnly, unspecified }

enum EventVisibility { public, private, hidden }

enum EventStatus {
  draft,
  published,
  full,
  ongoing,
  ended,
  cancelled,
  suspended,
  archived,
}

enum ApprovalMode { manual, automatic }

enum RequestStatus { pending, accepted, rejected, withdrawn, expired }

enum MatchStatus { active, eventEnded, cancelled, blocked }

enum MessageType { text, image, system }

enum NotificationType {
  requestReceived,
  requestAccepted,
  requestRejected,
  newMatch,
  newMessage,
  addressUnlocked,
  eventStartingSoon,
  eventCancelled,
  eventFull,
  djRequest,
  djProposal,
  premiumLike,
  boostExpired,
}

enum ReportReason {
  harassment,
  fakeProfile,
  underageUser,
  violence,
  drugs,
  unsafeLocation,
  scam,
  hateSpeech,
  sexualMisconduct,
  spam,
  illegalActivity,
  other,
}

enum ReportStatus { submitted, reviewing, actioned, dismissed }

enum SubscriptionTier { free, premiumMonthly, premiumAnnual }

enum BoostStatus { draft, active, expired, cancelled }

extension PullupEnumLabel on Enum {
  String get label {
    switch (this) {
      case EventCategory.houseParty:
        return 'House party';
      case EventCategory.poolParty:
        return 'Pool party';
      case EventCategory.rooftop:
        return 'Rooftop';
      case EventCategory.preGame:
        return 'Pre-game';
      case EventCategory.boatParty:
        return 'Boat party';
      case EventCategory.villaParty:
        return 'Villa party';
      case EventCategory.apartmentParty:
        return 'Apartment party';
      case EventCategory.privateDjSet:
        return 'Private DJ set';
      case EventCategory.studentParty:
        return 'Student party';
      case EventCategory.otherNightPlan:
        return 'Other night plan';
      case EventTag.byob:
        return 'BYOB';
      case EventTag.dj:
        return 'DJ';
      case EventTag.djNeeded:
        return 'DJ needed';
      case VerificationBadge.verifiedDj:
        return 'Verified DJ';
      default:
        final words = name.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)!.toLowerCase()}',
        );
        return words[0].toUpperCase() + words.substring(1);
    }
  }
}

const musicGenreOptions = [
  'House',
  'Afro',
  'Rap',
  'R&B',
  'Techno',
  'Reggaeton',
  'Hip-hop',
  'Commercial',
  'Cocktails',
  'Rooftops',
  'Pool parties',
  'Boat parties',
  'Afters',
  'Festivals',
  'Student nights',
];
