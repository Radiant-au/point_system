import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/point_expiry_group.dart';

// A replaceable clock makes the calendar-day calculations easy to test.
final expiryClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

class PointExpiryRepository {
  PointExpiryRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final DateTime Function() _clock;

  Future<List<PointExpiryGroup>> fetchGroups() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final today = _clock();
    // Demo dates stay in the future; replace this method with the expiry API.
    final date = DateTime(today.year, today.month, today.day + 25);
    return [
      PointExpiryGroup(points: 120, expiryDate: date),
      PointExpiryGroup(points: 200, expiryDate: date),
    ];
  }
}

final expiryRepositoryProvider = Provider<PointExpiryRepository>(
  (ref) => PointExpiryRepository(clock: ref.watch(expiryClockProvider)),
);

final expiryGroupsProvider =
    AsyncNotifierProvider<ExpiryGroupsNotifier, List<PointExpiryGroup>>(
      ExpiryGroupsNotifier.new,
      retry: (retryCount, error) => null,
    );

class ExpiryGroupsNotifier extends AsyncNotifier<List<PointExpiryGroup>> {
  @override
  Future<List<PointExpiryGroup>> build() =>
      ref.watch(expiryRepositoryProvider).fetchGroups();

  Future<void> refresh() async {
    if (state.isLoading) return;
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {
      // The shared AsyncValue exposes errors and keeps the previous groups.
    }
  }
}

// Derive from .value so the last groups remain visible even after a refresh error.
final expirySummaryProvider = Provider<ExpirySummary?>((ref) {
  final groups = ref.watch(expiryGroupsProvider).value;
  final today = ref.watch(expiryClockProvider)();
  return groups == null ? null : ExpirySummary.fromGroups(groups, today);
});
