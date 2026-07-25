import '../../../models/enums.dart';
import '../../../models/geo_point_lite.dart';
import '../../../models/professional_profile.dart';
import '../../../models/attendance_breakdown.dart';

class SignUpDraft {
  const SignUpDraft({
    required this.firstName,
    required this.displayName,
    required this.birthDate,
    required this.gender,
    required this.city,
    required this.email,
    required this.password,
    required this.acceptedTerms,
    required this.confirmedMinimumAge,
    this.lastName,
    this.phoneNumber,
    this.accountType = AccountType.personal,
    this.professionalCategory,
  });

  final String firstName;
  final String? lastName;
  final String displayName;
  final DateTime birthDate;
  final Gender gender;
  final String city;
  final String? phoneNumber;
  final String email;
  final String password;
  final bool acceptedTerms;
  final bool confirmedMinimumAge;
  final AccountType accountType;
  final ProfessionalCategory? professionalCategory;
}

class ProfileUpdateDraft {
  const ProfileUpdateDraft({
    required this.displayName,
    required this.bio,
    required this.city,
    required this.interests,
    required this.musicPreferences,
    required this.languages,
    required this.profilePhotos,
    this.occupation,
    this.instagramHandle,
    this.professionalProfile,
  });

  final String displayName;
  final String bio;
  final String city;
  final List<String> interests;
  final List<String> musicPreferences;
  final List<String> languages;
  final List<String> profilePhotos;
  final String? occupation;
  final String? instagramHandle;
  final ProfessionalProfile? professionalProfile;
}

class CreateEventDraft {
  const CreateEventDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.coverPhotoUrl,
    required this.photoUrls,
    required this.city,
    required this.areaName,
    required this.approximateGeoPoint,
    required this.exactAddress,
    required this.startDateTime,
    required this.endDateTime,
    required this.timezone,
    required this.ageRequirement,
    required this.maxParticipants,
    required this.allowsGroups,
    required this.maxGroupSize,
    required this.eventTags,
    required this.musicGenres,
    required this.alcoholPolicy,
    required this.smokingPolicy,
    required this.visibility,
    required this.approvalMode,
    required this.attendance,
    required this.entryFeeCents,
    required this.foodPolicy,
    required this.pillPolicy,
    this.accessInstructions,
    this.dressCode,
    this.contributionText,
    this.houseRules,
    this.publishAsProfessional = false,
    this.professionalNeeds = const [],
  });

  final String title;
  final String description;
  final EventCategory category;
  final String coverPhotoUrl;
  final List<String> photoUrls;
  final String city;
  final String areaName;
  final GeoPointLite approximateGeoPoint;
  final String exactAddress;
  final String? accessInstructions;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String timezone;
  final int ageRequirement;
  final int maxParticipants;
  final bool allowsGroups;
  final int maxGroupSize;
  final List<EventTag> eventTags;
  final List<String> musicGenres;
  final String? dressCode;
  final String? contributionText;
  final String? houseRules;
  final AlcoholPolicy alcoholPolicy;
  final SmokingPolicy smokingPolicy;
  final EventVisibility visibility;
  final ApprovalMode approvalMode;
  final AttendanceBreakdown attendance;
  final int entryFeeCents;
  final FoodPolicy foodPolicy;
  final PillPolicy pillPolicy;
  final bool publishAsProfessional;
  final List<ProfessionalCategory> professionalNeeds;
}

class JoinEventDraft {
  const JoinEventDraft({
    required this.note,
    required this.groupSize,
    this.companionNames = const [],
    this.companionUserIds = const [],
    this.guestMenCount = 0,
    this.guestWomenCount = 0,
  });

  final String note;
  final int groupSize;
  final List<String> companionNames;
  final List<String> companionUserIds;
  final int guestMenCount;
  final int guestWomenCount;
}
