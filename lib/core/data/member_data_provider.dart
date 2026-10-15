import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../network/rewards_api.dart';
import 'initial_member_data.dart';
import 'member_repository.dart';
import 'member_snapshot.dart';

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

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => MemberRepository(
    ref.watch(appDatabaseProvider),
    RewardsApi(ref.watch(dioProvider)),
    const String.fromEnvironment('API_MEMBER_ID', defaultValue: initialMemberId),
  ),
);

final memberDataProvider = AsyncNotifierProvider<MemberDataNotifier, MemberSnapshot>(
  MemberDataNotifier.new,
  retry: (retryCount, error) => null,
);

class MemberDataNotifier extends AsyncNotifier<MemberSnapshot> {
  @override
  Future<MemberSnapshot> build() =>
      ref.watch(memberRepositoryProvider).load();

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
