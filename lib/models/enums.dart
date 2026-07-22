enum Gender { woman, man, nonBinary, other, preferNotToSay }

enum AccountType { personal, professional }

enum ProfessionalCategory {
  dj,
  photographer,
  videographer,
  bartender,
  security,
  venue,
  bar,
  promoter,
  eventPlanner,
  other,
}

enum PortfolioMediaType { image, video, audio, link }

enum EventOrganizerType { privateHost, professional, venue }

enum GuestInteractionMode { approvalRequest, openInterest }

enum EventRequestKind { guest, professionalService }

enum VerificationBadge {
  emailVerified,
  phoneVerified,
  selfieVerified,
  identityVerified,
  verifiedHost,
  verifiedDj,
  verifiedProfessional,
  verifiedVenue,
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
  professionalRequest,
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
      case VerificationBadge.verifiedProfessional:
        return 'Verified professional';
      case VerificationBadge.verifiedVenue:
        return 'Verified venue';
      case ProfessionalCategory.dj:
        return 'DJ';
      case ProfessionalCategory.bar:
        return 'Bar';
      case ProfessionalCategory.eventPlanner:
        return 'Event planner';
      case EventOrganizerType.privateHost:
        return 'Private event';
      case EventOrganizerType.professional:
        return 'Professional event';
      case EventOrganizerType.venue:
        return 'Venue event';
      default:
        final words = name.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)!.toLowerCase()}',
        );
        return words[0].toUpperCase() + words.substring(1);
    }
  }
}

const professionalCategoryOptions = <ProfessionalCategory>[
  ProfessionalCategory.dj,
  ProfessionalCategory.photographer,
  ProfessionalCategory.videographer,
  ProfessionalCategory.bartender,
  ProfessionalCategory.security,
  ProfessionalCategory.venue,
  ProfessionalCategory.bar,
  ProfessionalCategory.promoter,
  ProfessionalCategory.eventPlanner,
  ProfessionalCategory.other,
];

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
