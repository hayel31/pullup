import 'package:intl/intl.dart';

class TimeUtils {
  const TimeUtils._();

  static String eventWindow(
    DateTime start,
    DateTime end, {
    String locale = 'en',
  }) {
    final date = DateFormat('EEE d MMM', locale);
    final time = DateFormat('HH:mm', locale);
    return '${date.format(start)} · ${time.format(start)} - ${time.format(end)}';
  }

  static String tonightCountdown(
    DateTime start,
    DateTime end, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    if (current.isAfter(start) && current.isBefore(end)) {
      final hours = end.difference(current).inHours.clamp(1, 99);
      return 'Happening now - ends in ${hours}h';
    }
    final diff = start.difference(current);
    if (diff.inMinutes <= 0) {
      return 'Starting now';
    }
    if (diff.inHours == 0) {
      return 'Starts in ${diff.inMinutes} min';
    }
    return 'Starts in ${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
  }
}
