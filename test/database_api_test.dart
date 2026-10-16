import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/core/data/member_repository.dart';
import 'package:point_system/core/data/member_snapshot.dart';
import 'package:point_system/core/database/app_database.dart';
import 'package:point_system/core/network/rewards_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/member_snapshot_fixture.dart';

// Override the widget-test HTTP stub only for the local server test.
class LocalHttpOverrides extends HttpOverrides {}

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.respond);
  Future<ResponseBody> Function(RequestOptions) respond;
  RequestOptions? lastRequest;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object body, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late AppDatabase database;
  late String filePath;
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('galaxy-rewards-test-');
    filePath = '${directory.path}/rewards.db';
    database = AppDatabase(
      factory: databaseFactoryFfiNoIsolate,
      path: filePath,
    );
    await database.save(memberSnapshotFixture());
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('SQLite persists cached rewards across reopen', () async {
    final initial = (await database.read(testMemberId))!;
    expect(initial.balance, 1450);
    expect(initial.transactions, hasLength(6));
    expect(initial.expiryGroups.map((group) => group.isoDate), [
      '2026-04-30',
      '2026-04-30',
    ]);
    final json = initial.toJson()..['balance'] = 1750;
    json['transactions'] = [(json['transactions'] as List).first];
    await database.save(MemberSnapshot.fromJson(json));
    await database.close();
    database = AppDatabase(
      factory: databaseFactoryFfiNoIsolate,
      path: filePath,
    );
    final restored = (await database.read(testMemberId))!;
    expect(restored.balance, 1750);
    expect(restored.transactions, hasLength(1));
    expect(restored.expiryGroups.first.isoDate, '2026-04-30');
  });

  test(
    'upgrade removes legacy credential columns and preserves cached rows',
    () async {
      final legacyPath = '${directory.path}/legacy.db';
      final legacyDatabase = await databaseFactoryFfiNoIsolate.openDatabase(
        legacyPath,
        options: OpenDatabaseOptions(
          version: 5,
          onCreate: (db, version) async {
            await db.execute('''
            CREATE TABLE members (
              id TEXT PRIMARY KEY NOT NULL,
              name TEXT NOT NULL,
              phone TEXT NOT NULL,
              membership_type TEXT NOT NULL,
              points_balance INTEGER NOT NULL,
              password_salt TEXT,
              password_hash TEXT
            )
          ''');
            await db.execute('''
            CREATE TABLE point_transactions (
              id TEXT PRIMARY KEY NOT NULL,
              member_id TEXT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
              branch TEXT NOT NULL,
              points INTEGER NOT NULL,
              occurred_at TEXT NOT NULL
            )
          ''');
            await db.execute('''
            CREATE TABLE expiry_groups (
              id TEXT PRIMARY KEY NOT NULL,
              member_id TEXT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
              points INTEGER NOT NULL,
              expiry_date TEXT NOT NULL
            )
          ''');
            await db.execute('''
            CREATE TABLE member_credentials (
              member_id TEXT PRIMARY KEY NOT NULL REFERENCES members(id) ON DELETE CASCADE,
              password TEXT NOT NULL,
              phone TEXT NOT NULL DEFAULT ''
            )
          ''');
            await db.execute('''
            CREATE INDEX transactions_by_member_date
            ON point_transactions(member_id, occurred_at DESC)
          ''');
            await db.execute('''
            CREATE INDEX expiry_by_member_date
            ON expiry_groups(member_id, expiry_date)
          ''');
            await db.insert('members', {
              'id': testMemberId,
              'name': 'Cached Member',
              'phone': '09111111111',
              'membership_type': 'Gold',
              'points_balance': 1450,
              'password_salt': 'legacy-salt',
              'password_hash': 'legacy-hash',
            });
            await db.insert('member_credentials', {
              'member_id': testMemberId,
              'password': 'legacy-password',
              'phone': '09111111111',
            });
            await db.insert('point_transactions', {
              'id': 'cached-transaction',
              'member_id': testMemberId,
              'branch': 'Cached Branch',
              'points': 50,
              'occurred_at': '2026-04-05T10:30:00.000Z',
            });
            await db.insert('expiry_groups', {
              'id': 'cached-expiry',
              'member_id': testMemberId,
              'points': 120,
              'expiry_date': '2026-04-30',
            });
          },
        ),
      );
      await legacyDatabase.close();

      await database.close();
      database = AppDatabase(
        factory: databaseFactoryFfiNoIsolate,
        path: legacyPath,
      );
      final cached = (await database.read(testMemberId))!;
      expect(cached.balance, 1450);
      expect(cached.transactions.single.id, 'cached-transaction');
      expect(cached.expiryGroups.single.id, 'cached-expiry');

      final db = await database.database;
      final columns = await db.rawQuery('PRAGMA table_info(members)');
      expect(
        columns.map((column) => column['name']),
        isNot(contains('password_salt')),
      );
      expect(
        columns.map((column) => column['name']),
        isNot(contains('password_hash')),
      );
      expect(
        await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'member_credentials'",
        ),
        isEmpty,
      );
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  test('schema enforces foreign keys and balance constraints', () async {
    final db = await database.database;
    final memberColumns = await db.rawQuery('PRAGMA table_info(members)');
    expect(
      memberColumns.map((column) => column['name']),
      isNot(contains('password_salt')),
    );
    expect(
      memberColumns.map((column) => column['name']),
      isNot(contains('password_hash')),
    );
    expect(
      await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'member_credentials'",
      ),
      isEmpty,
    );
    await expectLater(
      db.insert('expiry_groups', {
        'id': 'orphan',
        'member_id': 'missing',
        'points': 20,
        'expiry_date': '2026-04-30',
      }),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      db.rawUpdate('UPDATE members SET points_balance = -1 WHERE id = ?', [
        testMemberId,
      ]),
      throwsA(isA<DatabaseException>()),
    );
    expect((await database.read(testMemberId))!.balance, 1450);
  });

  test('failed snapshot write rolls back all tables without affecting another member', () async {
    final json = memberSnapshotFixture().toJson();
    json['member'] = {
      ...json['member'] as Map<String, dynamic>,
      'id': 'other-member',
    };
    // txn-1 already belongs to the first member: IDs are globally unique.
    await expectLater(
      database.save(MemberSnapshot.fromJson(json)),
      throwsA(isA<DatabaseException>()),
    );
    expect(await database.read('other-member'), isNull);
    final original = (await database.read(testMemberId))!;
    expect(original.balance, 1450);
    expect(original.transactions, hasLength(6));
    expect(original.expiryGroups, hasLength(2));
  });

  test(
    'Dio request preserves the base path and saves the complete response',
    () async {
      final json = memberSnapshotFixture().toJson()..['balance'] = 1900;
      json['member'] = {
        ...json['member'] as Map<String, dynamic>,
        'name': 'Updated Member',
      };
      final adapter = TestAdapter((_) async => jsonResponse(json));
      final dio = createDio('https://example.invalid/api')
        ..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));
      final repository = MemberRepository(
        database,
        RewardsApi(dio),
        testMemberId,
      );
      final fresh = await repository.load();
      expect(
        adapter.lastRequest!.uri.toString(),
        'https://example.invalid/api/members/$testMemberId/rewards',
      );
      expect(adapter.lastRequest!.headers['Accept'], 'application/json');
      expect(fresh.member.name, 'Updated Member');
      final stored = (await database.read(testMemberId))!;
      expect(stored.balance, 1900);
      expect(stored.member.name, 'Updated Member');
      expect(stored.transactions, hasLength(6));
    },
  );

  test('network failure uses saved SQLite rows, but authentication errors propagate', () async {
    final adapter = TestAdapter(
      (options) async => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'offline',
      ),
    );
    final dio = createDio('https://example.invalid/api/')
      ..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));
    final repository = MemberRepository(
      database,
      RewardsApi(dio),
      testMemberId,
    );
    final offline = await repository.load();
    expect(offline.balance, 1450);
    expect(offline.usingSavedData, isTrue);
    adapter.respond = (_) async =>
        jsonResponse({'error': 'unauthorized'}, status: 401);
    await expectLater(repository.load(), throwsA(isA<DioException>()));
    expect((await database.read(testMemberId))!.balance, 1450);
  });

  test('invalid API data cannot replace a valid SQLite cache', () async {
    final adapter = TestAdapter(
      (_) async => jsonResponse({
        'member': {'id': testMemberId},
      }),
    );
    final dio = createDio('https://example.invalid/api/')
      ..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));
    final repository = MemberRepository(
      database,
      RewardsApi(dio),
      testMemberId,
    );
    await expectLater(repository.load(), throwsA(isA<FormatException>()));
    final wrongMember = memberSnapshotFixture().toJson();
    wrongMember['member'] = {
      ...wrongMember['member'] as Map<String, dynamic>,
      'id': 'wrong-member',
    };
    adapter.respond = (_) async => jsonResponse(wrongMember);
    await expectLater(repository.load(), throwsA(isA<FormatException>()));
    expect((await database.read(testMemberId))!.balance, 1450);
    expect(await database.read('wrong-member'), isNull);
  });

  test(
    'JSON validation rejects duplicate IDs and invalid dates before a write',
    () {
      final badDate = memberSnapshotFixture().toJson();
      (badDate['expiry_groups'] as List).first['expiry_date'] = '2026-02-31';
      expect(() => MemberSnapshot.fromJson(badDate), throwsFormatException);
      final duplicate = memberSnapshotFixture().toJson();
      (duplicate['transactions'] as List).add(
        (duplicate['transactions'] as List).first,
      );
      expect(() => MemberSnapshot.fromJson(duplicate), throwsFormatException);
    },
  );
  test(
    'Dio performs a real HTTP GET against a local API fixture',
    () => HttpOverrides.runWithHttpOverrides(() async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requestedPath = Completer<String>();
      final body = memberSnapshotFixture().toJson()..['balance'] = 1650;
      server.listen((request) async {
        requestedPath.complete(request.uri.path);
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode(body));
        await request.response.close();
      });
      final dio = createDio('http://127.0.0.1:${server.port}/api/');
      addTearDown(() => dio.close(force: true));
      final repository = MemberRepository(
        database,
        RewardsApi(dio),
        testMemberId,
      );
      final response = await repository.load();
      expect(await requestedPath.future, '/api/members/$testMemberId/rewards');
      expect(response.balance, 1650);
      expect((await database.read(testMemberId))!.balance, 1650);
    }, LocalHttpOverrides()),
  );
}
