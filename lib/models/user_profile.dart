import '../core/utils/age_utils.dart';
import 'enums.dart';
import 'geo_point_lite.dart';
import 'professional_profile.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.firstName,
    required this.birthDate,
    required this.gender,
    required this.city,
    required this.approximateLocation,
    required this.profilePhotos,
    required this.interests,
    required this.musicPreferences,
    required this.languages,
    required this.verificationStatus,
    required this.phoneVerified,
    required this.selfieVerified,
    required this.identityVerified,
    required this.isPremium,
    required this.isDj,
    required this.isHost,
    required this.hostRating,
    required this.hostedEventCount,
    required this.guestAttendanceCount,
    required this.reportCount,
    required this.blockedUserIds,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActiveAt,
    required this.accountStatus,
    required this.onboardingCompleted,
    this.friendIds = const [],
    this.lastName,
    this.bio = '',
    this.mainPhotoUrl,
    this.occupation,
    this.instagramHandle,
    this.accountType = AccountType.personal,
    this.professionalProfile,
  });

  final String id;
  final String email;
  final String displayName;
  final String firstName;
  final String? lastName;
  final DateTime birthDate;
  final Gender gender;
  final String bio;
  final String city;
  final GeoPointLite approximateLocation;
  final List<String> profilePhotos;
  final String? mainPhotoUrl;
  final List<String> interests;
  final List<String> musicPreferences;
  final List<String> languages;
  final String? occupation;
  final String? instagramHandle;
  final VerificationStatus verificationStatus;
  final bool phoneVerified;
  final bool selfieVerified;
  final bool identityVerified;
  final bool isPremium;
  final bool isDj;
  final bool isHost;
  final double hostRating;
  final int hostedEventCount;
  final int guestAttendanceCount;
  final int reportCount;
  final List<String> blockedUserIds;
  final List<String> friendIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActiveAt;
  final AccountStatus accountStatus;
  final bool onboardingCompleted;
  final AccountType accountType;
  final ProfessionalProfile? professionalProfile;

  int get age => AgeUtils.ageFromBirthDate(birthDate);
  bool get isProfessional => accountType == AccountType.professional;
  ProfessionalCategory? get professionalCategory =>
      professionalProfile?.category;

  List<VerificationBadge> get badges {
    final result = <VerificationBadge>[];
    if (verificationStatus.index >= VerificationStatus.email.index) {
      result.add(VerificationBadge.emailVerified);
    }
    if (phoneVerified) result.add(VerificationBadge.phoneVerified);
    if (selfieVerified) result.add(VerificationBadge.selfieVerified);
    if (identityVerified) result.add(VerificationBadge.identityVerified);
    if (isHost) result.add(VerificationBadge.verifiedHost);
    if (isDj) result.add(VerificationBadge.verifiedDj);
    if (professionalProfile?.isVerified ?? false) {
      result.add(
        professionalProfile!.isVenue
            ? VerificationBadge.verifiedVenue
            : VerificationBadge.verifiedProfessional,
      );
    }
    if (hostedEventCount >= 10 && reportCount == 0) {
      result.add(VerificationBadge.superHost);
    }
    return result;
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    Gender? gender,
    String? bio,
    String? city,
    GeoPointLite? approximateLocation,
    List<String>? profilePhotos,
    String? mainPhotoUrl,
    List<String>? interests,
    List<String>? musicPreferences,
    List<String>? languages,
    String? occupation,
    String? instagramHandle,
    VerificationStatus? verificationStatus,
    bool? phoneVerified,
    bool? selfieVerified,
    bool? identityVerified,
    bool? isPremium,
    bool? isDj,
    bool? isHost,
    double? hostRating,
    int? hostedEventCount,
    int? guestAttendanceCount,
    int? reportCount,
    List<String>? blockedUserIds,
    List<String>? friendIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActiveAt,
    AccountStatus? accountStatus,
    bool? onboardingCompleted,
    AccountType? accountType,
    ProfessionalProfile? professionalProfile,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      approximateLocation: approximateLocation ?? this.approximateLocation,
      profilePhotos: profilePhotos ?? this.profilePhotos,
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
      interests: interests ?? this.interests,
      musicPreferences: musicPreferences ?? this.musicPreferences,
      languages: languages ?? this.languages,
      occupation: occupation ?? this.occupation,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      selfieVerified: selfieVerified ?? this.selfieVerified,
      identityVerified: identityVerified ?? this.identityVerified,
      isPremium: isPremium ?? this.isPremium,
      isDj: isDj ?? this.isDj,
      isHost: isHost ?? this.isHost,
      hostRating: hostRating ?? this.hostRating,
      hostedEventCount: hostedEventCount ?? this.hostedEventCount,
      guestAttendanceCount: guestAttendanceCount ?? this.guestAttendanceCount,
      reportCount: reportCount ?? this.reportCount,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
      friendIds: friendIds ?? this.friendIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      accountStatus: accountStatus ?? this.accountStatus,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      accountType: accountType ?? this.accountType,
      professionalProfile: professionalProfile ?? this.professionalProfile,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'firstName': firstName,
    'lastName': lastName,
    'birthDate': birthDate.toIso8601String(),
    'age': age,
    'gender': gender.name,
    'bio': bio,
    'city': city,
    'approximateLocation': approximateLocation.toJson(),
    'profilePhotos': profilePhotos,
    'mainPhotoUrl': mainPhotoUrl,
    'interests': interests,
    'musicPreferences': musicPreferences,
    'languages': languages,
    'occupation': occupation,
    'instagramHandle': instagramHandle,
    'verificationStatus': verificationStatus.name,
    'phoneVerified': phoneVerified,
    'selfieVerified': selfieVerified,
    'identityVerified': identityVerified,
    'isPremium': isPremium,
    'isDj': isDj,
    'isHost': isHost,
    'hostRating': hostRating,
    'hostedEventCount': hostedEventCount,
    'guestAttendanceCount': guestAttendanceCount,
    'reportCount': reportCount,
    'blockedUserIds': blockedUserIds,
    'friendIds': friendIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastActiveAt': lastActiveAt.toIso8601String(),
    'accountStatus': accountStatus.name,
    'onboardingCompleted': onboardingCompleted,
    'accountType': accountType.name,
    'professionalProfile': professionalProfile?.toJson(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: _enumValue(Gender.values, json['gender'], Gender.preferNotToSay),
      bio: json['bio'] as String? ?? '',
      city: json['city'] as String,
      approximateLocation: GeoPointLite.fromJson(
        Map<String, dynamic>.from(json['approximateLocation'] as Map),
      ),
      profilePhotos: List<String>.from(
        json['profilePhotos'] as List? ?? const [],
      ),
      mainPhotoUrl: json['mainPhotoUrl'] as String?,
      interests: List<String>.from(json['interests'] as List? ?? const []),
      musicPreferences: List<String>.from(
        json['musicPreferences'] as List? ?? const [],
      ),
      languages: List<String>.from(json['languages'] as List? ?? const []),
      occupation: json['occupation'] as String?,
      instagramHandle: json['instagramHandle'] as String?,
      verificationStatus: _enumValue(
        VerificationStatus.values,
        json['verificationStatus'],
        VerificationStatus.email,
      ),
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      selfieVerified: json['selfieVerified'] as bool? ?? false,
      identityVerified: json['identityVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      isDj: json['isDj'] as bool? ?? false,
      isHost: json['isHost'] as bool? ?? false,
      hostRating: (json['hostRating'] as num?)?.toDouble() ?? 0,
      hostedEventCount: json['hostedEventCount'] as int? ?? 0,
      guestAttendanceCount: json['guestAttendanceCount'] as int? ?? 0,
      reportCount: json['reportCount'] as int? ?? 0,
      blockedUserIds: List<String>.from(
        json['blockedUserIds'] as List? ?? const [],
      ),
      friendIds: List<String>.from(json['friendIds'] as List? ?? const []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      accountStatus: _enumValue(
        AccountStatus.values,
        json['accountStatus'],
        AccountStatus.active,
      ),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      accountType: _enumValue(
        AccountType.values,
        json['accountType'],
        AccountType.personal,
      ),
      professionalProfile: json['professionalProfile'] == null
          ? null
          : ProfessionalProfile.fromJson(
              Map<String, dynamic>.from(json['professionalProfile'] as Map),
            ),
    );
  }
}

T _enumValue<T extends Enum>(Iterable<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
