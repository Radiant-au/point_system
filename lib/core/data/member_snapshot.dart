import '../../features/expiry/models/point_expiry_group.dart';
import '../../features/history/models/point_transaction.dart';
import '../../features/member/models/member.dart';

class MemberSnapshot {
  MemberSnapshot({
    required this.member,
    required this.balance,
    required List<PointTransaction> transactions,
    required List<PointExpiryGroup> expiryGroups,
    this.usingSavedData = false,
  }) : transactions = List.unmodifiable(transactions),
       expiryGroups = List.unmodifiable(expiryGroups);

  final Member member;
  final int balance;
  final List<PointTransaction> transactions;
  final List<PointExpiryGroup> expiryGroups;
  final bool usingSavedData;

  MemberSnapshot asSavedData() => MemberSnapshot(
    member: member,
    balance: balance,
    transactions: transactions,
    expiryGroups: expiryGroups,
    usingSavedData: true,
  );

  // Validate the entire response before replacing any rows in SQLite.
  factory MemberSnapshot.fromJson(Map<String, dynamic> json) {
    final member = _object(json['member'], 'member');
    final balance = _integer(json['balance'], 'balance');
    if (balance < 0) throw const FormatException('Balance cannot be negative');
    final transactions = _list(json['transactions'], 'transactions').map((
      item,
    ) {
      final row = _object(item, 'transaction');
      final points = _integer(row['points'], 'transaction.points');
      if (points == 0) {
        throw const FormatException('Transaction points cannot be zero');
      }
      final timestamp = _string(row['occurred_at'], 'occurred_at');
      if (!RegExp(
        r'^\d{4}-\d{2}-\d{2}T(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d(?:\.\d{1,9})?(?:Z|[+-](?:[01]\d|2[0-3]):[0-5]\d)$',
      ).hasMatch(timestamp)) {
        throw const FormatException(
          'occurred_at must be an ISO timestamp with a timezone',
        );
      }
      _date(timestamp.substring(0, 10));
      return PointTransaction(
        id: _string(row['id'], 'transaction.id'),
        branch: _string(row['branch'], 'branch'),
        points: points,
        occurredAt: DateTime.parse(timestamp).toUtc(),
      );
    }).toList();
    final groups = _list(json['expiry_groups'], 'expiry_groups').map((item) {
      final row = _object(item, 'expiry group');
      final points = _integer(row['points'], 'expiry.points');
      if (points <= 0) {
        throw const FormatException('Expiry points must be positive');
      }
      return PointExpiryGroup(
        id: _string(row['id'], 'expiry.id'),
        points: points,
        expiryDate: _date(_string(row['expiry_date'], 'expiry_date')),
      );
    }).toList();
    _uniqueIds(transactions.map((row) => row.id));
    _uniqueIds(groups.map((row) => row.id));
    if (groups.fold(0, (sum, group) => sum + group.points) > balance) {
      throw const FormatException('Expiry groups exceed the point balance');
    }
    return MemberSnapshot(
      member: Member(
        id: _string(member['id'], 'member.id'),
        name: _string(member['name'], 'name'),
        phone: _string(member['phone'], 'phone'),
        type: _string(member['type'], 'type'),
      ),
      balance: balance,
      transactions: transactions,
      expiryGroups: groups,
    );
  }

  Map<String, dynamic> toJson() => {
    'member': {
      'id': member.id,
      'name': member.name,
      'phone': member.phone,
      'type': member.type,
    },
    'balance': balance,
    'transactions': [
      for (final row in transactions)
        {
          'id': row.id,
          'branch': row.branch,
          'points': row.points,
          'occurred_at': row.occurredAt.toUtc().toIso8601String(),
        },
    ],
    'expiry_groups': [
      for (final group in expiryGroups)
        {'id': group.id, 'points': group.points, 'expiry_date': group.isoDate},
    ],
  };
}

Map<String, dynamic> _object(Object? value, String field) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$field must be an object');
  }
  return value;
}

List<dynamic> _list(Object? value, String field) {
  if (value is! List) throw FormatException('$field must be an array');
  return value;
}

String _string(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$field must be a non-empty string');
  }
  return value;
}

int _integer(Object? value, String field) {
  if (value is! int) throw FormatException('$field must be an integer');
  return value;
}

DateTime _date(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw const FormatException('Expected YYYY-MM-DD');
  }
  final date = DateTime.parse(value);
  if (date.year.toString().padLeft(4, '0') != value.substring(0, 4) ||
      date.month != int.parse(value.substring(5, 7)) ||
      date.day != int.parse(value.substring(8, 10))) {
    throw const FormatException('Invalid calendar date');
  }
  return date;
}

void _uniqueIds(Iterable<String> ids) {
  final values = ids.toList();
  if (values.toSet().length != values.length) {
    throw const FormatException('Duplicate record IDs');
  }
}
