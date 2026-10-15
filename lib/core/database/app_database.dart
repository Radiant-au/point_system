import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../data/initial_member_data.dart';
import '../data/member_snapshot.dart';
import 'database_location.dart';
import 'password_hash.dart';

class AppDatabase {
  AppDatabase({this.factory, this.path, this.seedDemoData = false, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final bool seedDemoData;
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
        version: 5,
        singleInstance: false,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          final schema = await rootBundle.loadString(
            'assets/database/schema.sql',
          );
          for (final sql in schema.split(';')) {
            if (sql.trim().isNotEmpty) await db.execute(sql);
          }
          if (!seedDemoData) return;
          // onCreate already runs in a transaction. Seed only on first creation.
          await _write(db, createInitialMemberData(_clock()));
          final password = await hashPassword(initialPassword);
          await db.update(
            'members',
            {'password_salt': password.salt, 'password_hash': password.hash},
            where: 'id = ?',
            whereArgs: [initialMemberId],
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
              CREATE TABLE member_credentials (
                phone TEXT PRIMARY KEY NOT NULL,
                password TEXT NOT NULL
              )
            ''');
            await db.insert('member_credentials', {
              'phone': _localPhone(initialPhone),
              'password': initialPassword,
            });
          }
          if (oldVersion < 3) {
            await db.execute(
              'ALTER TABLE member_credentials RENAME TO old_member_credentials',
            );
            await db.execute('''
              CREATE TABLE member_credentials (
                member_id TEXT PRIMARY KEY NOT NULL REFERENCES members(id) ON DELETE CASCADE,
                password TEXT NOT NULL
              )
            ''');
            await db.execute('''
              INSERT INTO member_credentials (member_id, password)
              SELECT ?, password FROM old_member_credentials LIMIT 1
            ''', [initialMemberId]);
            await db.execute('DROP TABLE old_member_credentials');
          }
          if (oldVersion < 4) {
            await db.execute(
              "ALTER TABLE member_credentials ADD COLUMN phone TEXT NOT NULL DEFAULT ''",
            );
            await db.execute(
              'CREATE UNIQUE INDEX credential_phone ON member_credentials(phone)',
            );
            await db.update(
              'member_credentials',
              {'phone': _localPhone(initialPhone)},
              where: 'member_id = ?',
              whereArgs: [initialMemberId],
            );
            await db.update(
              'members',
              {'phone': initialPhone},
              where: 'id = ?',
              whereArgs: [initialMemberId],
            );
          }
          if (oldVersion < 5) {
            await db.execute('ALTER TABLE members ADD COLUMN password_salt TEXT');
            await db.execute('ALTER TABLE members ADD COLUMN password_hash TEXT');
            final credentials = await db.query('member_credentials');
            for (final credential in credentials) {
              final password = await hashPassword(credential['password']! as String);
              await db.update(
                'members',
                {'password_salt': password.salt, 'password_hash': password.hash},
                where: 'id = ?',
                whereArgs: [credential['member_id']],
              );
            }
            if (credentials.isEmpty) {
              final password = await hashPassword(initialPassword);
              await db.update(
                'members',
                {'password_salt': password.salt, 'password_hash': password.hash},
                where: 'id = ?',
                whereArgs: [initialMemberId],
              );
            }
            await db.execute('DROP TABLE member_credentials');
          }
        },
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

  Future<bool> authenticate(String phone, String password) async {
    final members = await (await database).query(
      'members',
      columns: ['phone', 'password_salt', 'password_hash'],
    );
    final normalizedPhone = _localPhone(phone);
    for (final member in members) {
      if (_localPhone(member['phone']! as String) != normalizedPhone) continue;
      final salt = member['password_salt'] as String?;
      final savedHash = member['password_hash'] as String?;
      if (salt == null || savedHash == null) return false;
      final candidate = await hashPassword(password, salt: salt);
      return passwordHashesMatch(candidate.hash, savedHash);
    }
    return false;
  }

  Future<bool> updatePassword(
    String memberId,
    String currentPassword,
    String newPassword,
  ) async {
    final db = await database;
    return db.transaction((txn) async {
      final members = await txn.query(
        'members',
        columns: ['password_salt', 'password_hash'],
        where: 'id = ?',
        whereArgs: [memberId],
        limit: 1,
      );
      if (members.isEmpty) return false;
      final salt = members.single['password_salt'] as String?;
      final savedHash = members.single['password_hash'] as String?;
      if (salt == null || savedHash == null) return false;
      final currentHash = await hashPassword(currentPassword, salt: salt);
      if (!passwordHashesMatch(currentHash.hash, savedHash)) return false;
      final next = await hashPassword(newPassword);
      await txn.update(
        'members',
        {'password_salt': next.salt, 'password_hash': next.hash},
        where: 'id = ?',
        whereArgs: [memberId],
      );
      return true;
    });
  }

  Future<void> _write(DatabaseExecutor db, MemberSnapshot snapshot) async {
    final member = snapshot.member;
    final existing = await db.query(
      'members',
      columns: ['password_salt', 'password_hash'],
      where: 'id = ?',
      whereArgs: [member.id],
      limit: 1,
    );
    final batch = db.batch();
    batch.insert('members', {
      'id': member.id,
      'name': member.name,
      'phone': member.phone,
      'membership_type': member.type,
      'points_balance': snapshot.balance,
      'password_salt': existing.isEmpty ? null : existing.single['password_salt'],
      'password_hash': existing.isEmpty ? null : existing.single['password_hash'],
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

String _localPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return digits.startsWith('95') ? '0${digits.substring(2)}' : digits;
}
