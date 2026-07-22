import 'enums.dart';

class ProfessionalPortfolioItem {
  const ProfessionalPortfolioItem({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String url;
  final PortfolioMediaType type;
  final String? thumbnailUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'type': type.name,
    'thumbnailUrl': thumbnailUrl,
  };

  factory ProfessionalPortfolioItem.fromJson(Map<String, dynamic> json) {
    return ProfessionalPortfolioItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: _enumValue(
        PortfolioMediaType.values,
        json['type'],
        PortfolioMediaType.link,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}

class ProfessionalProfile {
  const ProfessionalProfile({
    required this.category,
    required this.businessName,
    required this.headline,
    required this.description,
    required this.services,
    required this.portfolioItems,
    required this.completedProjects,
    required this.establishments,
    required this.socialLinks,
    required this.travelRadiusKm,
    required this.availability,
    required this.isVerified,
    this.website,
    this.indicativeRate,
    this.yearsExperience = 0,
  });

  final ProfessionalCategory category;
  final String businessName;
  final String headline;
  final String description;
  final List<String> services;
  final List<ProfessionalPortfolioItem> portfolioItems;
  final List<String> completedProjects;
  final List<String> establishments;
  final Map<String, String> socialLinks;
  final String? website;
  final double travelRadiusKm;
  final String? indicativeRate;
  final String availability;
  final int yearsExperience;
  final bool isVerified;

  bool get isVenue =>
      category == ProfessionalCategory.bar ||
      category == ProfessionalCategory.venue;

  ProfessionalProfile copyWith({
    ProfessionalCategory? category,
    String? businessName,
    String? headline,
    String? description,
    List<String>? services,
    List<ProfessionalPortfolioItem>? portfolioItems,
    List<String>? completedProjects,
    List<String>? establishments,
    Map<String, String>? socialLinks,
    String? website,
    double? travelRadiusKm,
    String? indicativeRate,
    String? availability,
    int? yearsExperience,
    bool? isVerified,
  }) {
    return ProfessionalProfile(
      category: category ?? this.category,
      businessName: businessName ?? this.businessName,
      headline: headline ?? this.headline,
      description: description ?? this.description,
      services: services ?? this.services,
      portfolioItems: portfolioItems ?? this.portfolioItems,
      completedProjects: completedProjects ?? this.completedProjects,
      establishments: establishments ?? this.establishments,
      socialLinks: socialLinks ?? this.socialLinks,
      website: website ?? this.website,
      travelRadiusKm: travelRadiusKm ?? this.travelRadiusKm,
      indicativeRate: indicativeRate ?? this.indicativeRate,
      availability: availability ?? this.availability,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'businessName': businessName,
    'headline': headline,
    'description': description,
    'services': services,
    'portfolioItems': portfolioItems.map((item) => item.toJson()).toList(),
    'completedProjects': completedProjects,
    'establishments': establishments,
    'socialLinks': socialLinks,
    'website': website,
    'travelRadiusKm': travelRadiusKm,
    'indicativeRate': indicativeRate,
    'availability': availability,
    'yearsExperience': yearsExperience,
    'isVerified': isVerified,
  };

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfile(
      category: _enumValue(
        ProfessionalCategory.values,
        json['category'],
        ProfessionalCategory.other,
      ),
      businessName: json['businessName'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      services: List<String>.from(json['services'] as List? ?? const []),
      portfolioItems: (json['portfolioItems'] as List? ?? const [])
          .map(
            (item) => ProfessionalPortfolioItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      completedProjects: List<String>.from(
        json['completedProjects'] as List? ?? const [],
      ),
      establishments: List<String>.from(
        json['establishments'] as List? ?? const [],
      ),
      socialLinks: Map<String, String>.from(
        json['socialLinks'] as Map? ?? const {},
      ),
      website: json['website'] as String?,
      travelRadiusKm: (json['travelRadiusKm'] as num?)?.toDouble() ?? 25,
      indicativeRate: json['indicativeRate'] as String?,
      availability: json['availability'] as String? ?? '',
      yearsExperience: json['yearsExperience'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

T _enumValue<T extends Enum>(Iterable<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
