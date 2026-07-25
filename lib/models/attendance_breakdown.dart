class AttendanceBreakdown {
  const AttendanceBreakdown({
    required this.initialMenCount,
    required this.initialWomenCount,
    required this.initialOtherCount,
    required this.currentMenCount,
    required this.currentWomenCount,
    required this.currentOtherCount,
  });

  const AttendanceBreakdown.empty()
    : initialMenCount = 0,
      initialWomenCount = 0,
      initialOtherCount = 0,
      currentMenCount = 0,
      currentWomenCount = 0,
      currentOtherCount = 0;

  factory AttendanceBreakdown.initial({
    required int men,
    required int women,
    required int other,
  }) {
    return AttendanceBreakdown(
      initialMenCount: men,
      initialWomenCount: women,
      initialOtherCount: other,
      currentMenCount: men,
      currentWomenCount: women,
      currentOtherCount: other,
    );
  }

  final int initialMenCount;
  final int initialWomenCount;
  final int initialOtherCount;
  final int currentMenCount;
  final int currentWomenCount;
  final int currentOtherCount;

  int get initialTotal =>
      initialMenCount + initialWomenCount + initialOtherCount;
  int get currentTotal =>
      currentMenCount + currentWomenCount + currentOtherCount;
  bool get isValid =>
      initialMenCount >= 0 &&
      initialWomenCount >= 0 &&
      initialOtherCount >= 0 &&
      currentMenCount >= initialMenCount &&
      currentWomenCount >= initialWomenCount &&
      currentOtherCount >= initialOtherCount;

  double shareFor(int count) => currentTotal == 0 ? 0 : count / currentTotal;

  AttendanceBreakdown addAcceptedGroup({
    required int men,
    required int women,
    required int other,
  }) {
    if (men < 0 || women < 0 || other < 0) {
      throw ArgumentError('Attendance increments cannot be negative.');
    }
    return AttendanceBreakdown(
      initialMenCount: initialMenCount,
      initialWomenCount: initialWomenCount,
      initialOtherCount: initialOtherCount,
      currentMenCount: currentMenCount + men,
      currentWomenCount: currentWomenCount + women,
      currentOtherCount: currentOtherCount + other,
    );
  }

  Map<String, dynamic> toJson() => {
    'initialMenCount': initialMenCount,
    'initialWomenCount': initialWomenCount,
    'initialOtherCount': initialOtherCount,
    'currentMenCount': currentMenCount,
    'currentWomenCount': currentWomenCount,
    'currentOtherCount': currentOtherCount,
  };

  factory AttendanceBreakdown.fromJson(
    Map<String, dynamic>? json, {
    int fallbackCurrentOtherCount = 0,
  }) {
    if (json == null) {
      return AttendanceBreakdown.initial(
        men: 0,
        women: 0,
        other: fallbackCurrentOtherCount,
      );
    }
    return AttendanceBreakdown(
      initialMenCount: json['initialMenCount'] as int? ?? 0,
      initialWomenCount: json['initialWomenCount'] as int? ?? 0,
      initialOtherCount: json['initialOtherCount'] as int? ?? 0,
      currentMenCount: json['currentMenCount'] as int? ?? 0,
      currentWomenCount: json['currentWomenCount'] as int? ?? 0,
      currentOtherCount:
          json['currentOtherCount'] as int? ?? fallbackCurrentOtherCount,
    );
  }
}
