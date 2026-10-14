class PointTransaction {
  const PointTransaction({
    required this.id,
    required this.branch,
    required this.points,
    required this.occurredAt,
  });
  final String id;
  final String branch;
  final int points;
  final DateTime occurredAt;
  bool get isEarned => points > 0;

  String get date {
    final local = occurredAt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String get time {
    final local = occurredAt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    return '$hour:${local.minute.toString().padLeft(2, '0')} ${local.hour < 12 ? 'AM' : 'PM'}';
  }
}
