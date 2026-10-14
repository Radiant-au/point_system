import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/rewards_load_state.dart';
import '../../../core/widgets/reward_widgets.dart';
import '../../points/widgets/point_balance.dart';
import '../providers/member_provider.dart';

class MemberCardScreen extends ConsumerWidget {
  const MemberCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(memberProvider);
    if (member == null) return const RewardsLoadState();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            RewardPageHeader(
              title: 'Member Card',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: RewardCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 224),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: QrImageView(
                              data: member.id,
                              version: QrVersions.auto,
                              padding: const EdgeInsets.all(10),
                              backgroundColor: Colors.white,
                              semanticsLabel:
                                  'Checkout QR code for member ${member.id}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _MemberDetail(
                        label: 'Member Name',
                        child: Text(member.name),
                      ),
                      const SizedBox(height: 4),
                      _MemberDetail(
                        label: 'Member Type',
                        child: Text(member.type),
                      ),
                      const SizedBox(height: 4),
                      _MemberDetail(
                        label: 'Member ID',
                        child: Text(
                          member.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: .7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const _MemberDetail(
                        label: 'Balance',
                        child: PointBalance(),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCCE0FF)),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFF4086E2),
                              child: Icon(
                                Icons.credit_card,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scan at Checkout',
                                    style: TextStyle(
                                      color: AppTheme.blue,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Present this code at the cashier to earn or redeem points',
                                    style: TextStyle(
                                      color: Color(0xFF344054),
                                      fontSize: 11,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberDetail extends StatelessWidget {
  const _MemberDetail({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.canvas,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.muted, fontSize: 11),
        ),
        const SizedBox(height: 8),
        DefaultTextStyle.merge(
          style: const TextStyle(color: AppTheme.ink, fontSize: 14),
          child: child,
        ),
      ],
    ),
  );
}
