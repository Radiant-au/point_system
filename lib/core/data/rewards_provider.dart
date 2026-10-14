import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../network/rewards_api.dart';
import 'demo_rewards.dart';
import 'rewards_repository.dart';
import 'rewards_snapshot.dart';

final appClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase(clock: ref.watch(appClockProvider));
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final dioProvider = Provider<Dio>((ref) {
  final dio = createDio(const String.fromEnvironment('API_BASE_URL'));
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (ref) => RewardsRepository(
    ref.watch(appDatabaseProvider),
    RewardsApi(ref.watch(dioProvider)),
    const String.fromEnvironment('API_MEMBER_ID', defaultValue: demoMemberId),
  ),
);

final rewardsProvider = AsyncNotifierProvider<RewardsNotifier, RewardsSnapshot>(
  RewardsNotifier.new,
  retry: (retryCount, error) => null,
);

class RewardsNotifier extends AsyncNotifier<RewardsSnapshot> {
  @override
  Future<RewardsSnapshot> build() =>
      ref.watch(rewardsRepositoryProvider).load();

  Future<void> refresh() async {
    if (state.isLoading) return;
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {
      // Riverpod preserves the previous snapshot and exposes the refresh error.
    }
  }
}
