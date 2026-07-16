import 'enums.dart';

class DjProfile {
  const DjProfile({
    required this.id,
    required this.userId,
    required this.stageName,
    required this.bio,
    required this.photoUrl,
    required this.galleryUrls,
    required this.musicGenres,
    required this.city,
    required this.travelRadiusKm,
    required this.equipment,
    required this.availability,
    required this.isVerified,
    this.instagram,
    this.soundCloud,
    this.spotify,
    this.mixcloud,
    this.indicativeRate,
  });

  final String id;
  final String userId;
  final String stageName;
  final String bio;
  final String photoUrl;
  final List<String> galleryUrls;
  final List<String> musicGenres;
  final String city;
  final double travelRadiusKm;
  final List<String> equipment;
  final String availability;
  final String? indicativeRate;
  final String? instagram;
  final String? soundCloud;
  final String? spotify;
  final String? mixcloud;
  final bool isVerified;
}

class DjServiceRequest {
  const DjServiceRequest({
    required this.id,
    required this.eventId,
    required this.hostId,
    required this.djId,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String hostId;
  final String djId;
  final String message;
  final RequestStatus status;
  final DateTime createdAt;
}

class DjProposal {
  const DjProposal({
    required this.id,
    required this.requestId,
    required this.djId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.indicativeRate,
  });

  final String id;
  final String requestId;
  final String djId;
  final String message;
  final RequestStatus status;
  final DateTime createdAt;
  final String? indicativeRate;
}
