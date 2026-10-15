import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/member_data_provider.dart';

class MemberDataLoadState extends ConsumerWidget {
  const MemberDataLoadState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberDataProvider);
    return Center(
      child: state.hasError && !state.isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load rewards.'),
                TextButton(
                  onPressed: () => ref.read(memberDataProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
