import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../data/member_snapshot.dart';
import 'database_location.dart';

class AppDatabase {
  AppDatabase({this.factory, this.path});
  final DatabaseFactory? factory;
  final String? path;
  Future<Database>? _opening;

  Future<Database> get database =>
      _opening ??= _open().catchError((Object error, StackTrace stack) {
        _opening = null;
        Error.throwWithStackTrace(error, stack);
      });

  Future<Database> _open() async {
    final selectedFactory = factory;
    final selectedPath = path;
    final location = selectedFactory != null && selectedPath != null
        ? (selectedFactory, selectedPath)
        : await databaseLocation();
    return location.$1.openDatabase(
      location.$2,
      options: OpenDatabaseOptions(
        version: 6,
        singleInstance: false,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          final schema = await rootBundle.loadString(
            'assets/database/schema.sql',
          );
          for (final sql in schema.split(';')) {
            if (sql.trim().isNotEmpty) await db.execute(sql);
          }
        },
        onUpgrade: (db, oldVersion, newVersion) => _removeLegacyCredentials(db),
      ),
    );
  }

  Future<MemberSnapshot?> read(String memberId) async {
    final db = await database;
    return db.transaction((txn) async {
      final members = await txn.query(
        'members',
        where: 'id = ?',
        whereArgs: [memberId],
      );
      if (members.isEmpty) return null;
      final member = members.single;
      final transactions = await txn.query(
        'point_transactions',
        where: 'member_id = ?',
        whereArgs: [memberId],
        orderBy: 'occurred_at DESC, id',
      );
      final groups = await txn.query(
        'expiry_groups',
        where: 'member_id = ?',
        whereArgs: [memberId],
        orderBy: 'expiry_date, id',
      );
      return MemberSnapshot.fromJson({
        'member': {
          'id': member['id'],
          'name': member['name'],
          'phone': member['phone'],
          'type': member['membership_type'],
        },
        'balance': member['points_balance'],
        'transactions': transactions,
        'expiry_groups': groups,
      });
    });
  }

  Future<void> save(MemberSnapshot snapshot) async {
    // Validate objects too, including snapshots created outside the API parser.
    final validated = MemberSnapshot.fromJson(snapshot.toJson());
    final db = await database;
    await db.transaction((txn) => _write(txn, validated));
  }

  Future<void> _write(DatabaseExecutor db, MemberSnapshot snapshot) async {
    final member = snapshot.member;
    final batch = db.batch();
    batch.insert('members', {
      'id': member.id,
      'name': member.name,
      'phone': member.phone,
      'membership_type': member.type,
      'points_balance': snapshot.balance,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    // Foreign-key cascading removes this member's old child rows before insertion.
    for (final row in snapshot.transactions) {
      batch.insert('point_transactions', {
        'id': row.id,
        'member_id': member.id,
        'branch': row.branch,
        'points': row.points,
        'occurred_at': row.occurredAt.toUtc().toIso8601String(),
      });
    }
    for (final group in snapshot.expiryGroups) {
      batch.insert('expiry_groups', {
        'id': group.id,
        'member_id': member.id,
        'points': group.points,
        'expiry_date': group.isoDate,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final opening = _opening;
    if (opening == null) return;
    try {
      await (await opening).close();
    } finally {
      _opening = null;
    }
  }
}

Future<void> _removeLegacyCredentials(DatabaseExecutor db) async {
  final credentials = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'member_credentials'",
  );
  if (credentials.isNotEmpty) {
    await db.execute('DROP TABLE member_credentials');
  }

  final columns = await db.rawQuery('PRAGMA table_info(members)');
  if (!columns.any(
    (column) =>
        column['name'] == 'password_salt' || column['name'] == 'password_hash',
  )) {
    return;
  }

  await db.execute('ALTER TABLE members RENAME TO members_with_credentials');
  await db.execute('''
    CREATE TABLE members (
      id TEXT PRIMARY KEY NOT NULL,
      name TEXT NOT NULL,
      phone TEXT NOT NULL,
      membership_type TEXT NOT NULL,
      points_balance INTEGER NOT NULL CHECK (typeof(points_balance) = 'integer' AND points_balance >= 0)
    )
  ''');
  await db.execute('''
    INSERT INTO members (id, name, phone, membership_type, points_balance)
    SELECT id, name, phone, membership_type, points_balance
    FROM members_with_credentials
  ''');
  await db.execute('''
    CREATE TABLE point_transactions_new (
      id TEXT PRIMARY KEY NOT NULL,
      member_id TEXT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
      branch TEXT NOT NULL,
      points INTEGER NOT NULL CHECK (typeof(points) = 'integer' AND points != 0),
      occurred_at TEXT NOT NULL
    )
  ''');
  await db.execute('''
    INSERT INTO point_transactions_new (id, member_id, branch, points, occurred_at)
    SELECT id, member_id, branch, points, occurred_at FROM point_transactions
  ''');
  await db.execute('''
    CREATE TABLE expiry_groups_new (
      id TEXT PRIMARY KEY NOT NULL,
      member_id TEXT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
      points INTEGER NOT NULL CHECK (typeof(points) = 'integer' AND points > 0),
      expiry_date TEXT NOT NULL
    )
  ''');
  await db.execute('''
    INSERT INTO expiry_groups_new (id, member_id, points, expiry_date)
    SELECT id, member_id, points, expiry_date FROM expiry_groups
  ''');
  await db.execute('DROP TABLE point_transactions');
  await db.execute('DROP TABLE expiry_groups');
  await db.execute('DROP TABLE members_with_credentials');
  await db.execute(
    'ALTER TABLE point_transactions_new RENAME TO point_transactions',
  );
  await db.execute('ALTER TABLE expiry_groups_new RENAME TO expiry_groups');
  await db.execute('''
    CREATE INDEX transactions_by_member_date
    ON point_transactions(member_id, occurred_at DESC)
  ''');
  await db.execute('''
    CREATE INDEX expiry_by_member_date
    ON expiry_groups(member_id, expiry_date)
  ''');
}
