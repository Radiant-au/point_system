import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/core/data/initial_member_data.dart';
import 'package:point_system/core/data/member_data_provider.dart';
import 'package:point_system/core/data/member_snapshot.dart';
import 'package:point_system/core/database/app_database.dart';
import 'package:point_system/core/network/rewards_api.dart';
import 'package:point_system/core/network/auth_session.dart';
import 'package:point_system/core/theme/app_theme.dart';
import 'package:point_system/features/home/screens/home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  testWidgets(
    'SQLite data reaches Home, Profile, History, and expiry through Riverpod',
    (tester) async {
      final database = AppDatabase(
        seedDemoData: true,
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
        clock: () => DateTime(2026, 4, 5),
      );
      addTearDown(database.close);
      final dio = createDio('');
      addTearDown(() => dio.close(force: true));
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appClockProvider.overrideWithValue(() => DateTime(2026, 4, 5)),
          dioProvider.overrideWithValue(dio),
          authSessionProvider.overrideWithValue(
            AuthSession()..memberId = initialMemberId,
          ),
        ],
      );
      addTearDown(container.dispose);
      // Native SQLite I/O runs outside the widget binding's fake clock.
      await tester.runAsync(() => container.read(memberDataProvider.future));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1450'), findsOneWidget);
      expect(find.text('320 Points'), findsOneWidget);

      final json = createInitialMemberData(DateTime(2026, 4, 5)).toJson()
        ..['balance'] = 1600;
      json['member'] = {
        ...json['member'] as Map<String, dynamic>,
        'name': 'Database Member',
      };
      json['expiry_groups'] = [
        {'id': 'new-expiry', 'points': 45, 'expiry_date': '2026-04-10'},
      ];
      json['transactions'] = [
        {
          'id': 'new-transaction',
          'branch': 'Database Branch',
          'points': 150,
          'occurred_at': '2026-04-05T10:00:00Z',
        },
      ];
      await tester.runAsync(() async {
        await database.save(MemberSnapshot.fromJson(json));
        await tester.tap(find.byTooltip('Refresh points'));
        await container.read(memberDataProvider.future);
      });
      await tester.pumpAndSettle();
      expect(find.text('1600'), findsOneWidget);
      expect(find.text('45 Points'), findsOneWidget);
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Database Branch'), findsOneWidget);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Database Member'), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-expiry-card')));
      await tester.pumpAndSettle();
      expect(find.text('45 Points'), findsNWidgets(2));
      expect(find.text('5 days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
