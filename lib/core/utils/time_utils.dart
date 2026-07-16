import 'package:intl/intl.dart';

class TimeUtils {
  const TimeUtils._();

  static final _date = DateFormat('EEE d MMM');
  static final _time = DateFormat('HH:mm');

  static String eventWindow(DateTime start, DateTime end) {
    return '${_date.format(start)} - ${_time.format(start)} to ${_time.format(end)}';
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
