import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/reward_widgets.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      RewardPageHeader(title: 'Rewards', onBack: onBack),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rules',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              const SizedBox(height: 12),
              const RewardCard(
                child: Column(
                  children: [
                    _RuleRow(
                      earning: true,
                      label: 'Earn Points',
                      rule: '200 MMK = 1 Point',
                    ),
                    Divider(height: 24, color: Color(0xFFF0F1F3)),
                    _RuleRow(
                      earning: false,
                      label: 'Redeem Points',
                      rule: '1 Point = 1 MMK',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.earning,
    required this.label,
    required this.rule,
  });
  final bool earning;
  final String label;
  final String rule;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: earning
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFFE2E2),
          child: Icon(
            earning ? Icons.arrow_upward : Icons.arrow_downward,
            color: earning ? const Color(0xFF00B83E) : Colors.red,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppTheme.muted, fontSize: 11),
              ),
              const SizedBox(height: 6),
              Text(
                rule,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
