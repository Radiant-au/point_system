import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/member_data_provider.dart';

import 'package:dio/dio.dart';

import '../../features/auth/screens/login_screen.dart';

class MemberDataLoadState extends ConsumerWidget {
  const MemberDataLoadState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberDataProvider);
    final error = state.error;
    final needsLogin =
        error is DioException &&
        [401, 403].contains(error.response?.statusCode);
    return Center(
      child: state.hasError && !state.isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  needsLogin
                      ? 'Please sign in again.'
                      : 'Could not load rewards.',
                ),
                TextButton(
                  onPressed: () {
                    if (needsLogin) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                        (_) => false,
                      );
                    } else {
                      ref.read(memberDataProvider.notifier).refresh();
                    }
                  },
                  child: Text(needsLogin ? 'Sign in' : 'Retry'),
                ),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
