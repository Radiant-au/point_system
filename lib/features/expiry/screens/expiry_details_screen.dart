import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/data/member_data_provider.dart';
import '../../../core/widgets/reward_widgets.dart';
import '../models/point_expiry_group.dart';
import '../providers/expiry_provider.dart';

class ExpiryDetailsScreen extends ConsumerWidget {
  const ExpiryDetailsScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberDataProvider);
    final summary = ref.watch(expirySummaryProvider);
    final refresh = ref.read(memberDataProvider.notifier).refresh;
    return Column(
      children: [
        RewardPageHeader(title: 'Points Expiry Details', onBack: onBack),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                if (state.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                if (state.hasError) ...[
                  RewardCard(
                    child: Column(
                      children: [
                        const Text(
                          'Could not refresh expiry details.',
                          style: TextStyle(color: AppTheme.ink),
                        ),
                        if (summary != null)
                          const Text('Showing the last loaded points.'),
                        TextButton(
                          onPressed: state.isLoading ? null : refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (summary != null) ...[
                  _ExpiryTotalCard(total: summary.totalPoints),
                  const SizedBox(height: 20),
                  const Text(
                    'Point Groups by Expiry Date',
                    style: TextStyle(
                      color: AppTheme.ink,
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (summary.groups.isEmpty)
                    const RewardCard(
                      child: Text(
                        'No points expiring in the next 30 days.',
                        style: TextStyle(color: AppTheme.muted, fontSize: 14),
                      ),
                    )
                  else
                    for (final group in summary.groups) ...[
                      _ExpiryGroupCard(group: group, today: summary.asOfDate),
                      const SizedBox(height: 12),
                    ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpiryTotalCard extends StatelessWidget {
  const _ExpiryTotalCard({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) => RewardCard(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: Border.all(color: const Color(0xFFFFC994)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFFFEDD5),
              child: Icon(
                total > 0 ? Icons.error_outline : Icons.task_alt,
                color: const Color(0xFFFF4D00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Expiring (Next 30 Days)',
                    style: TextStyle(color: Color(0xFF4A5565), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total Points',
                    key: const Key('expiry-total'),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            border: Border.all(color: const Color(0xFFFFD7AE)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: total > 0
                      ? 'Action Required: '
                      : 'All points are active. ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: total > 0
                      ? 'Redeem these points before they expire to maximize your rewards!'
                      : 'None expiring in the next 30 days.',
                ),
              ],
            ),
            style: const TextStyle(
              color: Color(0xFFBA3500),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ExpiryGroupCard extends StatelessWidget {
  const _ExpiryGroupCard({required this.group, required this.today});
  final PointExpiryGroup group;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final days = group.daysRemaining(today);
    return RewardCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${group.points} Points',
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFFFEDD5),
                child: Icon(
                  Icons.trending_down,
                  color: Color(0xFFFF4D00),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DetailRow(label: 'Expiry Date:', value: group.formattedDate),
          const SizedBox(height: 10),
          _DetailRow(
            label: 'Days Remaining:',
            value: days == 0 ? 'Today' : '$days days',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF4A5565), fontSize: 11),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: const Color(0xFFFF4D00),
            fontSize: 11,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    ],
  );
}
