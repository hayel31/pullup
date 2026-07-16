import '../../../models/enums.dart';
import '../../../models/geo_point_lite.dart';

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
    this.accessInstructions,
    this.dressCode,
    this.contributionText,
    this.houseRules,
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
}

class JoinEventDraft {
  const JoinEventDraft({
    required this.note,
    required this.groupSize,
    required this.companionNames,
  });

  final String note;
  final int groupSize;
  final List<String> companionNames;
}
