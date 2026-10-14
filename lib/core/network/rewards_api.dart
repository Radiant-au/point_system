import 'package:dio/dio.dart';

import '../data/rewards_snapshot.dart';

class RewardsApi {
  RewardsApi(this.dio);
  final Dio dio;
  bool get isConfigured => dio.options.baseUrl.isNotEmpty;

  Future<RewardsSnapshot> fetch(String memberId) async {
    final response = await dio.get<Object?>(
      'members/${Uri.encodeComponent(memberId)}/rewards',
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Expected a rewards object');
    }
    final snapshot = RewardsSnapshot.fromJson(body);
    if (snapshot.member.id != memberId) {
      throw const FormatException('Unexpected member ID');
    }
    return snapshot;
  }
}

Dio createDio(String baseUrl) {
  final normalized = baseUrl.trim();
  if (normalized.isNotEmpty) {
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !['https', 'http'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException('API_BASE_URL must be an HTTP(S) base URL');
    }
  }
  return Dio(
    BaseOptions(
      baseUrl: normalized.isEmpty || normalized.endsWith('/')
          ? normalized
          : '$normalized/',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      headers: {'Accept': 'application/json'},
    ),
  );
}
