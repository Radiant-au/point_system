import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/core/data/initial_member_data.dart';
import 'package:point_system/core/data/member_data_provider.dart';
import 'package:point_system/core/data/member_snapshot.dart';
import 'package:point_system/features/points/providers/points_provider.dart';
import 'package:point_system/features/member/providers/member_provider.dart';
import 'package:point_system/features/expiry/providers/expiry_provider.dart';

import 'support/demo_member_repository.dart';

class ControlledMemberRepository extends DemoMemberRepository {
  final requests = <Completer<MemberSnapshot>>[];
  @override
  Future<MemberSnapshot> load() {
    final request = Completer<MemberSnapshot>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  test('refresh retains values, prevents duplicate requests, and updates derived providers', () async {
    final repository = ControlledMemberRepository();
    final container = ProviderContainer(
      overrides: [
        memberRepositoryProvider.overrideWithValue(repository),
        appClockProvider.overrideWithValue(() => DateTime(2026, 4, 5)),
      ],
    );
    addTearDown(container.dispose);
    final initial = container.read(memberDataProvider.future);
    repository.requests.first.complete(createInitialMemberData(DateTime(2026, 4, 5)));
    await initial;
    expect(container.read(pointsProvider), 1450);
    expect(container.read(expirySummaryProvider)!.totalPoints, 320);
    final refresh = container.read(memberDataProvider.notifier).refresh();
    expect(container.read(memberDataProvider).isLoading, isTrue);
    expect(container.read(pointsProvider), 1450);
    await container.read(memberDataProvider.notifier).refresh();
    expect(repository.requests, hasLength(2));
    final updated = createInitialMemberData(DateTime(2026, 4, 5)).toJson()
      ..['balance'] = 1600;
    updated['member'] = {
      ...updated['member'] as Map<String, dynamic>,
      'name': 'New Name',
    };
    updated['expiry_groups'] = [];
    repository.requests.last.complete(MemberSnapshot.fromJson(updated));
    await refresh;
    expect(container.read(pointsProvider), 1600);
    expect(container.read(memberProvider)!.name, 'New Name');
    expect(container.read(expirySummaryProvider)!.totalPoints, 0);
  });

  test(
    'failed refresh retains the entire snapshot and manual retry succeeds',
    () async {
      final repository = ControlledMemberRepository();
      final container = ProviderContainer(
        overrides: [
          memberRepositoryProvider.overrideWithValue(repository),
          appClockProvider.overrideWithValue(() => DateTime(2026, 4, 5)),
        ],
      );
      addTearDown(container.dispose);
      final initial = container.read(memberDataProvider.future);
      repository.requests.first.complete(
        createInitialMemberData(DateTime(2026, 4, 5)),
      );
      await initial;
      final refresh = container.read(memberDataProvider.notifier).refresh();
      repository.requests.last.completeError(StateError('Invalid response'));
      await refresh;
      expect(container.read(memberDataProvider).hasError, isTrue);
      expect(container.read(pointsProvider), 1450);
      expect(container.read(expirySummaryProvider)!.totalPoints, 320);
      final retry = container.read(memberDataProvider.notifier).refresh();
      repository.requests.last.complete(
        createInitialMemberData(DateTime(2026, 4, 5)),
      );
      await retry;
      expect(container.read(memberDataProvider).hasError, isFalse);
    },
  );
}
