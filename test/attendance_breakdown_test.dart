import 'package:flutter_test/flutter_test.dart';
import 'package:pullup/models/attendance_breakdown.dart';

void main() {
  test(
    'accepted groups update the current mix but preserve the initial mix',
    () {
      final initial = AttendanceBreakdown.initial(men: 2, women: 3, other: 1);
      final updated = initial.addAcceptedGroup(men: 1, women: 2, other: 1);

      expect(updated.initialTotal, 6);
      expect(updated.currentTotal, 10);
      expect(updated.currentMenCount, 3);
      expect(updated.currentWomenCount, 5);
      expect(updated.currentOtherCount, 2);
      expect(updated.isValid, isTrue);
    },
  );

  test('legacy events keep occupied seats as an unspecified mix', () {
    final migrated = AttendanceBreakdown.fromJson(
      null,
      fallbackCurrentOtherCount: 7,
    );

    expect(migrated.initialOtherCount, 7);
    expect(migrated.currentOtherCount, 7);
    expect(migrated.currentTotal, 7);
  });
}
