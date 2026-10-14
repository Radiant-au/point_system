import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/rewards_provider.dart';
import '../models/point_expiry_group.dart';

final expiryClockProvider = appClockProvider;
final expiryGroupsProvider = Provider<List<PointExpiryGroup>?>(
  (ref) => ref.watch(rewardsProvider).value?.expiryGroups,
);

final expirySummaryProvider = Provider<ExpirySummary?>((ref) {
  final groups = ref.watch(expiryGroupsProvider);
  final today = ref.watch(expiryClockProvider)();
  return groups == null ? null : ExpirySummary.fromGroups(groups, today);
});
