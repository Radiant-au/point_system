import 'package:dio/dio.dart';

import '../database/app_database.dart';
import '../network/rewards_api.dart';
import 'rewards_snapshot.dart';

class RewardsRepository {
  RewardsRepository(this.database, this.api, this.memberId);
  final AppDatabase database;
  final RewardsApi api;
  final String memberId;

  Future<RewardsSnapshot> load() async {
    final saved = await database.read(memberId);
    if (!api.isConfigured) {
      if (saved == null) throw StateError('No saved rewards for this member');
      return saved;
    }
    try {
      final fresh = await api.fetch(memberId);
      await database.save(fresh);
      return fresh;
    } on DioException catch (error) {
      // Network failures and temporary server outages may use the saved snapshot.
      // Auth failures and invalid responses are surfaced instead of cached.
      final networkFailure = [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ].contains(error.type);
      final serverFailure =
          error.type == DioExceptionType.badResponse &&
          (error.response?.statusCode ?? 0) >= 500;
      if (saved != null && (networkFailure || serverFailure)) {
        return saved.asSavedData();
      }
      rethrow;
    }
  }
}
