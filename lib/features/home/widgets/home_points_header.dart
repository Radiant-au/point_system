import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../expiry/widgets/home_expiry_card.dart';
import '../../points/widgets/point_balance.dart';

class HomePointsHeader extends StatelessWidget {
  const HomePointsHeader({super.key, required this.onOpenExpiry});
  final VoidCallback onOpenExpiry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 44),
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: const Column(
          children: [
            Text(
              'GALAXY REWARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Point Balance',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 12),
            PointBalance(onBlue: true),
          ],
        ),
      ),
      Align(
        heightFactor: .72,
        child: Transform.translate(
          offset: const Offset(0, -14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HomeExpiryCard(onOpen: onOpenExpiry),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
