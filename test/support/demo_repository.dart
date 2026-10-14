import 'package:point_system/core/data/demo_rewards.dart';
import 'package:point_system/core/data/rewards_repository.dart';
import 'package:point_system/core/data/rewards_snapshot.dart';
import 'package:point_system/core/database/app_database.dart';
import 'package:point_system/core/network/rewards_api.dart';
import 'package:point_system/features/expiry/models/point_expiry_group.dart';

class DemoRewardsRepository extends RewardsRepository {
  DemoRewardsRepository()
    : super(AppDatabase(), RewardsApi(createDio('')), demoMemberId);
  RewardsSnapshot snapshot = createDemoRewards(DateTime(2026, 4, 5));
  bool offline = false;

  set balance(int value) => snapshot = RewardsSnapshot.fromJson({
    ...snapshot.toJson(),
    'balance': value,
  });
  set groups(List<PointExpiryGroup> value) => snapshot = RewardsSnapshot(
    member: snapshot.member,
    balance: snapshot.balance,
    transactions: snapshot.transactions,
    expiryGroups: value,
  );

  @override
  Future<RewardsSnapshot> load() async {
    if (offline) throw StateError('Offline');
    return snapshot;
  }
}
