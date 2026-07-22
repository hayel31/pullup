import 'enums.dart';

class DiscoverFilter {
  const DiscoverFilter({
    required this.distanceKm,
    required this.minAge,
    required this.maxAge,
    required this.categories,
    required this.musicGenres,
    required this.tags,
    required this.organizerTypes,
    required this.professionalNeeds,
    required this.verifiedHostsOnly,
    required this.availableSpotsOnly,
    required this.tonightOnly,
    required this.nowOnly,
  });

  final double distanceKm;
  final int minAge;
  final int maxAge;
  final Set<EventCategory> categories;
  final Set<String> musicGenres;
  final Set<EventTag> tags;
  final Set<EventOrganizerType> organizerTypes;
  final Set<ProfessionalCategory> professionalNeeds;
  final bool verifiedHostsOnly;
  final bool availableSpotsOnly;
  final bool tonightOnly;
  final bool nowOnly;

  static const defaults = DiscoverFilter(
    distanceKm: 25,
    minAge: 18,
    maxAge: 45,
    categories: {},
    musicGenres: {},
    tags: {},
    organizerTypes: {},
    professionalNeeds: {},
    verifiedHostsOnly: false,
    availableSpotsOnly: true,
    tonightOnly: false,
    nowOnly: false,
  );

  DiscoverFilter copyWith({
    double? distanceKm,
    int? minAge,
    int? maxAge,
    Set<EventCategory>? categories,
    Set<String>? musicGenres,
    Set<EventTag>? tags,
    Set<EventOrganizerType>? organizerTypes,
    Set<ProfessionalCategory>? professionalNeeds,
    bool? verifiedHostsOnly,
    bool? availableSpotsOnly,
    bool? tonightOnly,
    bool? nowOnly,
  }) {
    return DiscoverFilter(
      distanceKm: distanceKm ?? this.distanceKm,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      categories: categories ?? this.categories,
      musicGenres: musicGenres ?? this.musicGenres,
      tags: tags ?? this.tags,
      organizerTypes: organizerTypes ?? this.organizerTypes,
      professionalNeeds: professionalNeeds ?? this.professionalNeeds,
      verifiedHostsOnly: verifiedHostsOnly ?? this.verifiedHostsOnly,
      availableSpotsOnly: availableSpotsOnly ?? this.availableSpotsOnly,
      tonightOnly: tonightOnly ?? this.tonightOnly,
      nowOnly: nowOnly ?? this.nowOnly,
    );
  }
}
