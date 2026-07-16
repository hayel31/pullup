import '../../app/constants/app_constants.dart';

class AgeUtils {
  const AgeUtils._();

  static int ageFromBirthDate(DateTime birthDate, {DateTime? now}) {
    final today = now ?? DateTime.now();
    var age = today.year - birthDate.year;
    final birthdayPassed =
        today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    if (!birthdayPassed) {
      age--;
    }
    return age;
  }

  static bool isMinimumAge(
    DateTime birthDate, {
    int minimumAge = AppConstants.minimumAge,
    DateTime? now,
  }) {
    return ageFromBirthDate(birthDate, now: now) >= minimumAge;
  }
}
