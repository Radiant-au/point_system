import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/features/points/providers/points_provider.dart';

class ControlledPointsRepository extends PointsRepository {
  final requests = <Completer<int>>[];

  @override
  Future<int> fetchBalance() {
    final request = Completer<int>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  test(
    'refresh keeps the balance, ignores duplicates, and publishes new points',
    () async {
      final repository = ControlledPointsRepository();
      final container = ProviderContainer(
        overrides: [pointsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final initial = container.read(pointsProvider.future);
      repository.requests.first.complete(1450);
      expect(await initial, 1450);

      final refresh = container.read(pointsProvider.notifier).refresh();
      expect(container.read(pointsProvider).isLoading, isTrue);
      expect(container.read(pointsProvider).value, 1450);
      await container.read(pointsProvider.notifier).refresh();
      expect(repository.requests, hasLength(2));

      repository.requests.last.complete(1500);
      await refresh;
      expect(container.read(pointsProvider).value, 1500);
      expect(container.read(pointsProvider).isLoading, isFalse);
    },
  );

  test('failed refresh retains the balance and can be retried', () async {
    final repository = ControlledPointsRepository();
    final container = ProviderContainer(
      overrides: [pointsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final initial = container.read(pointsProvider.future);
    repository.requests.first.complete(1450);
    await initial;

    final refresh = container.read(pointsProvider.notifier).refresh();
    repository.requests.last.completeError(Exception('Offline'));
    await refresh;
    expect(container.read(pointsProvider).hasError, isTrue);
    expect(container.read(pointsProvider).value, 1450);

    final retry = container.read(pointsProvider.notifier).refresh();
    repository.requests.last.complete(1600);
    await retry;
    expect(container.read(pointsProvider).hasError, isFalse);
    expect(container.read(pointsProvider).value, 1600);
  });
}
