import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/features/expiry/models/point_expiry_group.dart';

void main() {
  test('summary includes today and day 30, excludes invalid groups, and sorts dates', () {
    final today = DateTime(2026, 4, 5, 23, 59);
    final groups = [
      PointExpiryGroup(points: 200, expiryDate: DateTime(2026, 5, 5)),
      PointExpiryGroup(points: 120, expiryDate: DateTime(2026, 4, 30)),
      PointExpiryGroup(points: 10, expiryDate: DateTime(2026, 4, 5)),
      PointExpiryGroup(points: 50, expiryDate: DateTime(2026, 4, 4)),
      PointExpiryGroup(points: 75, expiryDate: DateTime(2026, 5, 6)),
      PointExpiryGroup(points: 0, expiryDate: DateTime(2026, 4, 10)),
      PointExpiryGroup(points: -20, expiryDate: DateTime(2026, 4, 10)),
    ];
    final summary = ExpirySummary.fromGroups(groups, today);
    expect(summary.totalPoints, 330);
    expect(summary.groups.map((group) => group.points), [10, 120, 200]);
    expect(groups.first.points, 200);
    expect(summary.groups[1].daysRemaining(today), 25);
    expect(summary.groups[1].formattedDate, '30/04/2026');
    expect(summary.groups.first.daysRemaining(today), 0);
  });

  test(
    'countdown uses calendar days across month and leap-year boundaries',
    () {
      final group = PointExpiryGroup(
        points: 120,
        expiryDate: DateTime(2028, 3, 1),
      );
      expect(group.daysRemaining(DateTime(2028, 2, 28, 23, 59)), 2);
      expect(group.daysRemaining(DateTime(2028, 3, 1, 23, 59)), 0);
      expect(group.daysRemaining(DateTime(2028, 3, 2)), -1);
    },
  );
}
