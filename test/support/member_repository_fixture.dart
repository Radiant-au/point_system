import 'package:point_system/core/data/member_repository.dart';
import 'package:point_system/core/data/member_snapshot.dart';
import 'package:point_system/core/database/app_database.dart';
import 'package:point_system/core/network/rewards_api.dart';
import 'package:point_system/features/expiry/models/point_expiry_group.dart';

import 'member_snapshot_fixture.dart';

class FixtureMemberRepository extends MemberRepository {
  FixtureMemberRepository()
    : super(AppDatabase(), RewardsApi(createDio('')), testMemberId);

  MemberSnapshot snapshot = memberSnapshotFixture();
  bool offline = false;

  set balance(int value) => snapshot = MemberSnapshot.fromJson({
    ...snapshot.toJson(),
    'balance': value,
  });

  set groups(List<PointExpiryGroup> value) => snapshot = MemberSnapshot(
    member: snapshot.member,
    balance: snapshot.balance,
    transactions: snapshot.transactions,
    expiryGroups: value,
  );

  @override
  Future<MemberSnapshot> load() async {
    if (offline) throw StateError('Offline');
    return snapshot;
  }
}
