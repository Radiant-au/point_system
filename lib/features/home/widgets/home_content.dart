import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../member/providers/member_provider.dart';

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
              const _PromotionCard(),
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

class _PromotionCard extends StatelessWidget {
  const _PromotionCard();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/promotion_photo.jpg',
            fit: BoxFit.cover,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 165),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 44),
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              child: Container(
                width: 213,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x66893813),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Double Points Weekend',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Earn 2x points on all purchases this weekend!',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 24,
          child: ColoredBox(
            color: const Color(0x66893813),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 6),
                const _PageDot(),
                const SizedBox(width: 6),
                const _PageDot(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _PageDot extends StatelessWidget {
  const _PageDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MembershipCard extends ConsumerWidget {
  const _MembershipCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(memberProvider);
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
