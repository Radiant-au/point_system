class PointExpiryGroup {
  const PointExpiryGroup({required this.points, required this.expiryDate});

  final int points;
  final DateTime expiryDate;

  int daysRemaining(DateTime today) {
    // Compare calendar dates so time-of-day and daylight saving cannot shift a day.
    final expiryDay = DateTime.utc(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );
    final currentDay = DateTime.utc(today.year, today.month, today.day);
    return expiryDay.difference(currentDay).inDays;
  }

  String get formattedDate =>
      '${expiryDate.day.toString().padLeft(2, '0')}/'
      '${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}';
}

class ExpirySummary {
  ExpirySummary.fromGroups(List<PointExpiryGroup> groups, this.asOfDate)
    : groups = List.unmodifiable(
        groups.where((group) {
          final remaining = group.daysRemaining(asOfDate);
          return group.points > 0 && remaining >= 0 && remaining <= 30;
        }).toList()..sort((a, b) => a.expiryDate.compareTo(b.expiryDate)),
      );

  final List<PointExpiryGroup> groups;
  final DateTime asOfDate;
  int get totalPoints => groups.fold(0, (total, group) => total + group.points);
}
