import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/core/data/member_data_provider.dart';
import 'package:point_system/core/database/app_database.dart';
import 'package:point_system/core/network/rewards_api.dart';
import 'package:point_system/core/network/auth_session.dart';
import 'package:point_system/core/theme/app_theme.dart';
import 'package:point_system/features/home/screens/home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/member_snapshot_fixture.dart';

void main() {
  sqfliteFfiInit();
  testWidgets(
    'SQLite data reaches Home, Profile, History, and expiry through Riverpod',
    (tester) async {
      final database = AppDatabase(
        factory: databaseFactoryFfiNoIsolate,
        path: inMemoryDatabasePath,
      );
      addTearDown(database.close);
      await tester.runAsync(() => database.save(memberSnapshotFixture()));
      final dio = createDio('');
      addTearDown(() => dio.close(force: true));
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appClockProvider.overrideWithValue(() => DateTime(2026, 4, 5)),
          dioProvider.overrideWithValue(dio),
          authSessionProvider.overrideWithValue(
            AuthSession()..memberId = testMemberId,
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

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Test Branch'), findsWidgets);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Test Member'), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-expiry-card')));
      await tester.pumpAndSettle();
      expect(find.text('120 Points'), findsOneWidget);
      expect(find.text('200 Points'), findsOneWidget);
      expect(find.text('25 days'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
}
