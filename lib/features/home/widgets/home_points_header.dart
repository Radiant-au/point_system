import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HomePointsHeader extends StatelessWidget {
  const HomePointsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 257,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 188,
            decoration: const BoxDecoration(
              gradient: AppTheme.blueGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          const Positioned(
            top: 12,
            left: 16,
            right: 16,
            height: 40,
            child: Center(
              child: Text(
                'GALAXY REWARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 64,
            left: 16,
            right: 16,
            height: 24,
            child: Center(
              child: Text(
                'Point Balance',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          Positioned(
            top: 96,
            left: 0,
            right: 0,
            height: 48,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '1450',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 157,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _ExpiryCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryCard extends StatelessWidget {
  const _ExpiryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFD7AE)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Points Expiring Soon',
                  style: TextStyle(color: Color(0xFFFF4D00), fontSize: 10),
                ),
                SizedBox(height: 4),
                Text(
                  '120 Points',
                  style: TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Expires on next 30 days.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4DF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF8A00),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
