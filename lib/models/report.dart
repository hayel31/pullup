import 'enums.dart';

class Report {
  const Report({
    required this.id,
    required this.reporterId,
    required this.reason,
    required this.description,
    required this.evidenceUrls,
    required this.status,
    required this.createdAt,
    this.reportedUserId,
    this.reportedEventId,
    this.reportedMessageId,
    this.reviewedAt,
    this.moderatorNotes,
  });

  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedEventId;
  final String? reportedMessageId;
  final ReportReason reason;
  final String description;
  final List<String> evidenceUrls;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? moderatorNotes;
}
