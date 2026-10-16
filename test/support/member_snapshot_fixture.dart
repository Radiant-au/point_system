import 'package:point_system/core/data/member_snapshot.dart';
import 'package:point_system/features/expiry/models/point_expiry_group.dart';
import 'package:point_system/features/history/models/point_transaction.dart';
import 'package:point_system/features/member/models/member.dart';

const testMemberId = 'test-member-1';

MemberSnapshot memberSnapshotFixture() => MemberSnapshot(
  member: const Member(
    id: testMemberId,
    name: 'Test Member',
    phone: '09111111111',
    type: 'Gold',
  ),
  balance: 1450,
  transactions: [
    PointTransaction(
      id: 'txn-1',
      branch: 'Test Branch',
      points: 50,
      occurredAt: DateTime.utc(2026, 4, 5, 10, 30),
    ),
    PointTransaction(
      id: 'txn-2',
      branch: 'Test Branch',
      points: -100,
      occurredAt: DateTime.utc(2026, 4, 4, 14, 15),
    ),
    PointTransaction(
      id: 'txn-3',
      branch: 'Test Branch',
      points: 75,
      occurredAt: DateTime.utc(2026, 4, 1, 17, 45),
    ),
    PointTransaction(
      id: 'txn-4',
      branch: 'Test Branch',
      points: -50,
      occurredAt: DateTime.utc(2026, 3, 30, 11, 20),
    ),
    PointTransaction(
      id: 'txn-5',
      branch: 'Test Branch',
      points: 30,
      occurredAt: DateTime.utc(2026, 3, 25, 15),
    ),
    PointTransaction(
      id: 'txn-6',
      branch: 'Test Branch',
      points: -500,
      occurredAt: DateTime.utc(2026, 3, 20, 13, 30),
    ),
  ],
  expiryGroups: [
    PointExpiryGroup(
      id: 'expiry-1',
      points: 120,
      expiryDate: DateTime(2026, 4, 30),
    ),
    PointExpiryGroup(
      id: 'expiry-2',
      points: 200,
      expiryDate: DateTime(2026, 4, 30),
    ),
  ],
);
