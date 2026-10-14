import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../data/demo_rewards.dart';
import '../data/rewards_snapshot.dart';
import 'database_location.dart';

class AppDatabase {
  AppDatabase({this.factory, this.path, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final DatabaseFactory? factory;
  final String? path;
  final DateTime Function() _clock;
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
        version: 1,
        singleInstance: false,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          final schema = await rootBundle.loadString(
            'assets/database/schema.sql',
          );
          for (final sql in schema.split(';')) {
            if (sql.trim().isNotEmpty) await db.execute(sql);
          }
          // onCreate already runs in a transaction. Seed only on first creation.
          await _write(db, createDemoRewards(_clock()));
        },
      ),
    );
  }

  Future<RewardsSnapshot?> read(String memberId) async {
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
      return RewardsSnapshot.fromJson({
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

  Future<void> save(RewardsSnapshot snapshot) async {
    // Validate objects too, including snapshots created outside the API parser.
    final validated = RewardsSnapshot.fromJson(snapshot.toJson());
    final db = await database;
    await db.transaction((txn) => _write(txn, validated));
  }

  Future<void> _write(DatabaseExecutor db, RewardsSnapshot snapshot) async {
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
