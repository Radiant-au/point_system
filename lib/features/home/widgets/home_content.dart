import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/member_data_load_state.dart';
import '../../member/providers/member_provider.dart';
import 'promotion_carousel.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.onOpenMemberCard});

  final VoidCallback onOpenMemberCard;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PromotionCarousel(),
              const SizedBox(height: 16),
              const Text(
                'My Card',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Semantics(
                button: true,
                label: 'Open member card',
                child: GestureDetector(
                  onTap: onOpenMemberCard,
                  child: const _MembershipCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembershipCard extends ConsumerWidget {
  const _MembershipCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(memberProvider);
    if (member == null) return const MemberDataLoadState();
    return Container(
      constraints: const BoxConstraints(minHeight: 184),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x804B97FF), Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -21,
            bottom: -42,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0x332C73D2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -47,
            top: 44,
            child: Container(
              width: 115,
              height: 115,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC900),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2364C2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/galaxy_reward_splash.svg',
                        width: 26,
                        height: 26,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GALAXY REWARD',
                          style: TextStyle(
                            color: Color(0xFF101828),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'REWARDS & MORE',
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 8,
                            letterSpacing: .2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  member.formattedId,
                  style: const TextStyle(
                    color: Color(0xFF1E2939),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .9,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _CardDetail(
                        label: 'CARD HOLDER',
                        value: member.name,
                      ),
                    ),
                    _CardDetail(label: 'TYPE', value: member.type),
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

class _CardDetail extends StatelessWidget {
  const _CardDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: label == 'TYPE'
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: label == 'TYPE' ? AppTheme.blue : const Color(0xFF1E2939),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
