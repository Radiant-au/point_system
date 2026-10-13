import 'package:flutter_riverpod/flutter_riverpod.dart';

class PointTransaction {
  const PointTransaction({
    required this.branch,
    required this.points,
    required this.date,
    required this.time,
  });
  final String branch;
  final int points;
  final String date;
  final String time;
  bool get isEarned => points > 0;
}

final historyProvider = Provider<List<PointTransaction>>(
  (ref) => const [
    PointTransaction(
      branch: 'Star City Branch',
      points: 50,
      date: '05/04/2026',
      time: '10:30 AM',
    ),
    PointTransaction(
      branch: 'Hlaing Branch',
      points: -100,
      date: '04/04/2026',
      time: '2:15 PM',
    ),
    PointTransaction(
      branch: 'M Tower',
      points: 75,
      date: '01/04/2026',
      time: '5:45 PM',
    ),
    PointTransaction(
      branch: 'M Tower',
      points: -50,
      date: '30/03/2026',
      time: '11:20 AM',
    ),
    PointTransaction(
      branch: 'Terminal M',
      points: 30,
      date: '25/03/2026',
      time: '3:00 PM',
    ),
    PointTransaction(
      branch: 'South Dagon Branch',
      points: -500,
      date: '20/03/2026',
      time: '1:30 PM',
    ),
  ],
);
