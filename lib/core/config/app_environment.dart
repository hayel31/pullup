enum AppEnvironmentName { development, staging, production }

class AppEnvironment {
  const AppEnvironment({
    required this.name,
    required this.useFirebase,
    required this.minimumAge,
  });

  final AppEnvironmentName name;
  final bool useFirebase;
  final int minimumAge;

  static AppEnvironment current() {
    const rawName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    const useFirebase = String.fromEnvironment('USE_FIREBASE') == 'true';
    const minimumAge = int.fromEnvironment('MINIMUM_AGE', defaultValue: 18);
    final name = AppEnvironmentName.values.firstWhere(
      (value) => value.name == rawName,
      orElse: () => AppEnvironmentName.development,
    );
    return AppEnvironment(
      name: name,
      useFirebase: useFirebase,
      minimumAge: minimumAge,
    );
  }
}
