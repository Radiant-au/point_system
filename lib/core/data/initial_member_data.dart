import '../../features/expiry/models/point_expiry_group.dart';
import '../../features/history/models/point_transaction.dart';
import '../../features/member/models/member.dart';
import 'member_snapshot.dart';

const initialMemberId = '1900190000956102';
const initialPhone = '09123456789';
const initialPassword = 'Galaxy123';

MemberSnapshot createInitialMemberData(DateTime createdAt) {
  final expiryDate = DateTime(
    createdAt.year,
    createdAt.month,
    createdAt.day + 25,
  );
  return MemberSnapshot(
    member: const Member(
      id: initialMemberId,
      name: 'Tint Zaw Htun',
      phone: initialPhone,
      type: 'Platinum',
    ),
    balance: 1450,
    transactions: [
      PointTransaction(
        id: 'txn-1',
        branch: 'Star City Branch',
        points: 50,
        occurredAt: DateTime(2026, 4, 5, 10, 30),
      ),
      PointTransaction(
        id: 'txn-2',
        branch: 'Hlaing Branch',
        points: -100,
        occurredAt: DateTime(2026, 4, 4, 14, 15),
      ),
      PointTransaction(
        id: 'txn-3',
        branch: 'M Tower',
        points: 75,
        occurredAt: DateTime(2026, 4, 1, 17, 45),
      ),
      PointTransaction(
        id: 'txn-4',
        branch: 'M Tower',
        points: -50,
        occurredAt: DateTime(2026, 3, 30, 11, 20),
      ),
      PointTransaction(
        id: 'txn-5',
        branch: 'Terminal M',
        points: 30,
        occurredAt: DateTime(2026, 3, 25, 15),
      ),
      PointTransaction(
        id: 'txn-6',
        branch: 'South Dagon Branch',
        points: -500,
        occurredAt: DateTime(2026, 3, 20, 13, 30),
      ),
    ],
    expiryGroups: [
      PointExpiryGroup(id: 'expiry-1', points: 120, expiryDate: expiryDate),
      PointExpiryGroup(id: 'expiry-2', points: 200, expiryDate: expiryDate),
    ],
  );
}
