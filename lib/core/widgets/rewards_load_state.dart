import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/rewards_provider.dart';

class RewardsLoadState extends ConsumerWidget {
  const RewardsLoadState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rewardsProvider);
    return Center(
      child: state.hasError && !state.isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load rewards.'),
                TextButton(
                  onPressed: () => ref.read(rewardsProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
