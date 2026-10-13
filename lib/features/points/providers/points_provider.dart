import 'package:flutter_riverpod/flutter_riverpod.dart';

// Replace this method with an API call when the backend is ready.
class PointsRepository {
  Future<int> fetchBalance() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 1450;
  }
}

final pointsRepositoryProvider = Provider<PointsRepository>(
  (ref) => PointsRepository(),
);

final pointsProvider = AsyncNotifierProvider<PointsNotifier, int>(
  PointsNotifier.new,
  retry: (retryCount, error) => null,
);

class PointsNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() => ref.watch(pointsRepositoryProvider).fetchBalance();

  Future<void> refresh() async {
    if (state.isLoading) return;
    // Riverpod keeps the previous balance while rebuilding this provider.
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {
      // AsyncValue already exposes the failure to the UI for manual retry.
    }
  }
}
