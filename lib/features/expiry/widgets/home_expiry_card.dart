import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/reward_widgets.dart';
import '../providers/expiry_provider.dart';

class HomeExpiryCard extends ConsumerWidget {
  const HomeExpiryCard({super.key, required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expiryGroupsProvider);
    final summary = ref.watch(expirySummaryProvider);
    final expiring = summary != null && summary.totalPoints > 0;
    final color = expiring ? const Color(0xFFFF4D00) : const Color(0xFF00B83E);
    final message = summary == null
        ? state.hasError
              ? 'Could not load expiry details.'
              : 'Checking expiry details…'
        : expiring
        ? '${summary.totalPoints} Points'
        : 'All points are active.';

    return RewardCard(
      padding: EdgeInsets.zero,
      border: Border.all(
        color: expiring ? const Color(0xFFFFD7AE) : const Color(0xFF70DC9A),
      ),
      child: InkWell(
        key: const Key('home-expiry-card'),
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (expiring) ...[
                      Text(
                        'Points Expiring Soon',
                        style: TextStyle(color: color, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      message,
                      style: TextStyle(
                        color: expiring ? AppTheme.ink : color,
                        fontSize: expiring ? 20 : 14,
                        fontWeight: expiring
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary == null
                          ? 'Tap to view details or retry.'
                          : expiring
                          ? 'Tap to view points expiring in the next 30 days.'
                          : 'None expiring in the next 30 days.',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: expiring
                    ? const Color(0xFFFFEDD5)
                    : const Color(0xFFDCFCE7),
                child: state.isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      )
                    : Icon(
                        expiring ? Icons.error_outline : Icons.chevron_right,
                        color: color,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
