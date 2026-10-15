import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_system/core/network/auth_session.dart';
import 'package:point_system/core/network/rewards_api.dart';

import 'database_api_test.dart' show TestAdapter, jsonResponse;

void main() {
  test('login selects returned member and sends bearer; logout removes it', () async {
    final dio = createDio('https://example.test/api/');
    addTearDown(() => dio.close(force: true));
    final session = AuthSession();
    session.attach(dio);
    final adapter = TestAdapter((request) async {
      if (request.path == 'auth/login') {
        expect(request.data['rememberMe'], isTrue);
        return jsonResponse({
          'accessToken': 'test-token',
          'expiresAt': DateTime.now().toUtc().add(const Duration(days: 30)).toIso8601String(),
          'member': {'id': 'server-member'},
        });
      }
      expect(request.headers['Authorization'], 'Bearer test-token');
      return jsonResponse({});
    });
    dio.httpClientAdapter = adapter;
    await session.login(dio, '09123456789', 'Example123', true);
    expect(session.memberId, 'server-member');
    await dio.get<Object?>('members/server-member/rewards');
    await session.logout(dio);
    expect(session.memberId, isNull);
    adapter.respond = (request) async {
      expect(request.headers['Authorization'], isNull);
      return jsonResponse({});
    };
    await dio.get<Object?>('health');
  });

  test('401 clears the session and remains an authentication error', () async {
    final dio = createDio('https://example.test/api/');
    addTearDown(() => dio.close(force: true));
    final session = AuthSession();
    session.attach(dio);
    final adapter = TestAdapter((_) async => jsonResponse({
      'accessToken': 'token',
      'expiresAt': DateTime.now().toUtc().add(const Duration(hours: 8)).toIso8601String(),
      'member': {'id': 'member'},
    }));
    dio.httpClientAdapter = adapter;
    await session.login(dio, '09123456789', 'Example123', false);
    adapter.respond = (_) async => jsonResponse({'title': 'Unauthorized'}, status: 401);
    await expectLater(dio.get<Object?>('members/member/rewards'), throwsA(isA<DioException>()));
    expect(session.memberId, isNull);
  });
}
