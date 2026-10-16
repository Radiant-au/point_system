import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/core/data/member_data_provider.dart';
import 'package:point_system/core/network/rewards_api.dart';
import 'package:point_system/core/theme/app_theme.dart';
import 'package:point_system/features/auth/screens/login_screen.dart';
import 'package:point_system/features/auth/screens/reset_password_screen.dart';
import 'package:point_system/features/home/screens/home_screen.dart';

import 'database_api_test.dart' show TestAdapter, jsonResponse;

import 'support/member_repository_fixture.dart';

import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('tabs, QR, shared point refresh, back, and sign out work', (
    tester,
  ) async {
    final repository = FixtureMemberRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [memberRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1450'), findsOneWidget);
    await tester.tap(find.text('Rewards'));
    await tester.pumpAndSettle();
    expect(find.text('200 MMK = 1 Point'), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Point History'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Point Balance'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.qr_code_2));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      tester.widget<QrImageView>(find.byType(QrImageView)).semanticsLabel,
      'Checkout QR code for member test-member-1',
    );
    repository.balance = 1520;
    await tester.ensureVisible(find.byTooltip('Refresh points'));
    await tester.tap(find.byTooltip('Refresh points'));
    await tester.pumpAndSettle();
    expect(find.text('1520'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('1520'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset validates requirements and confirmation before success', (
    tester,
  ) async {
    final dio = createDio('https://example.test/api/');
    dio.httpClientAdapter = TestAdapter((_) async => jsonResponse({}));
    addTearDown(() => dio.close(force: true));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dioProvider.overrideWithValue(dio)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ResetPasswordScreen(),
                  ),
                ),
                child: const Text('Open reset'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();
    expect(find.text('Meet all three password requirements'), findsOneWidget);
    expect(find.text('Confirm your password'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'CurrentPassword1');
    await tester.enterText(fields.at(1), 'Password1');
    await tester.enterText(fields.at(2), 'Password2');
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
    await tester.enterText(fields.at(2), 'Password1');
    await tester.tap(find.text('Update Password'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('Your password is updated successfully.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'new pages stay scrollable on a compact phone with the keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberRepositoryProvider.overrideWithValue(
              FixtureMemberRepository(),
            ),
          ],
          child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in ['Rewards', 'History', 'Profile']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Update Password'));
      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
