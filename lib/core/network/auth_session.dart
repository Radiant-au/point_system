import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authSessionProvider = Provider<AuthSession>((ref) => AuthSession());

// Session tokens stay in memory; passwords and tokens are never written to SQLite.
class AuthSession {
  String? memberId;
  String? _token;
  DateTime? _expiresAt;

  void attach(Dio dio) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (_token != null && _expiresAt!.isAfter(DateTime.now())) {
        options.headers['Authorization'] = 'Bearer $_token';
      }
      handler.next(options);
    }, onError: (error, handler) {
      if (error.response?.statusCode == 401) clear();
      handler.next(error);
    }));
  }

  Future<void> login(Dio dio, String phone, String password, bool rememberMe) async {
    final response = await dio.post<Map<String, dynamic>>('auth/login', data: {
      'phone': phone, 'password': password, 'rememberMe': rememberMe,
    });
    final body = response.data!;
    final token = body['accessToken'] as String;
    final id = (body['member'] as Map<String, dynamic>)['id'] as String;
    final expiry = DateTime.parse(body['expiresAt'] as String);
    _token = token;
    memberId = id;
    _expiresAt = expiry;
  }

  Future<void> logout(Dio dio) async {
    try {
      await dio.post<void>('auth/logout');
    } on DioException {
      // Always remove local access, including when the server is unavailable.
    } finally {
      clear();
    }
  }

  void clear() { memberId = null; _token = null; _expiresAt = null; }
}

String apiErrorMessage(Object error) {
  if (error is DioException) {
    final body = error.response?.data;
    if (body is Map && body['title'] is String) return body['title'] as String;
    return 'Unable to connect. Check your connection and try again.';
  }
  return 'Unable to complete the request. Please try again.';
}
