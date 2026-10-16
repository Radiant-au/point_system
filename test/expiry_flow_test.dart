import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/core/theme/app_theme.dart';
import 'package:point_system/features/expiry/models/point_expiry_group.dart';
import 'package:point_system/features/expiry/providers/expiry_provider.dart';
import 'package:point_system/core/data/member_data_provider.dart';

import 'support/member_repository_fixture.dart';

import 'package:point_system/features/home/screens/home_screen.dart';

Widget app(FixtureMemberRepository repository, {double textScale = 1}) =>
    ProviderScope(
      overrides: [
        memberRepositoryProvider.overrideWithValue(repository),
        expiryClockProvider.overrideWithValue(() => DateTime(2026, 4, 5)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const HomeScreen(),
      ),
    );

void main() {
  testWidgets(
    'Home opens expiry details, refresh updates both views, and empty state returns',
    (tester) async {
      final repository = FixtureMemberRepository();
      await tester.pumpWidget(app(repository));
      await tester.pumpAndSettle();
      expect(find.text('320 Points'), findsOneWidget);
      await tester.tap(find.byKey(const Key('home-expiry-card')));
      await tester.pumpAndSettle();
      expect(find.text('Points Expiry Details'), findsOneWidget);
      expect(find.text('120 Points'), findsOneWidget);
      expect(find.text('200 Points'), findsOneWidget);
      expect(find.text('30/04/2026'), findsNWidgets(2));
      expect(find.text('25 days'), findsNWidgets(2));
      expect(find.text('Home'), findsOneWidget);

      repository.groups = [
        PointExpiryGroup(points: 45, expiryDate: DateTime(2026, 4, 10)),
      ];
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 350));
      await tester.pumpAndSettle();
      expect(find.text('45 Points'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('45 Points'), findsOneWidget);

      await tester.tap(find.byKey(const Key('home-expiry-card')));
      await tester.pumpAndSettle();
      repository.groups = [];
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 350));
      await tester.pumpAndSettle();
      expect(find.text('0 Points'), findsOneWidget);
      expect(
        find.text('No points expiring in the next 30 days.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('All points are active.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('initial load error offers retry and recovers', (tester) async {
    final repository = FixtureMemberRepository()..offline = true;
    await tester.pumpWidget(app(repository));
    await tester.pumpAndSettle();
    expect(find.text('Could not load rewards.'), findsOneWidget);
    repository.offline = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('320 Points'), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-expiry-card')));
    await tester.pumpAndSettle();
    expect(find.text('Points Expiry Details'), findsOneWidget);
    expect(find.text('320 Points'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'expiry details adapt to small screens and system Back returns Home',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(FixtureMemberRepository(), textScale: 1.3));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-expiry-card')));
      await tester.pumpAndSettle();
      expect(find.text('Points Expiry Details'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Point Balance'), findsOneWidget);
      expect(find.text('Points Expiry Details'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
