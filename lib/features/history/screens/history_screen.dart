import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/member_data_load_state.dart';
import '../../../core/data/member_data_provider.dart';
import '../models/point_transaction.dart';
import '../../../core/widgets/reward_widgets.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(historyProvider);
    if (transactions == null) return const MemberDataLoadState();
    return Column(
      children: [
        RewardPageHeader(title: 'Point History', onBack: onBack),
        Expanded(
          child: transactions.isEmpty
              ? const Center(child: Text('No point history yet.'))
              : RefreshIndicator(
                  onRefresh: ref.read(memberDataProvider.notifier).refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: transactions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _TransactionCard(transaction: transactions[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});
  final PointTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final earned = transaction.isEarned;
    final color = earned ? const Color(0xFF00B83E) : Colors.red;
    return RewardCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: earned
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFFE2E2),
            child: Icon(
              earned ? Icons.trending_up : Icons.trending_down,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            earned ? 'Received from' : 'Redeemed at',
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.branch,
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${earned ? '+' : ''}${transaction.points}',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.date,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    Text(
                      transaction.time,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
