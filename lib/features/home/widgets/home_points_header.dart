import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/reward_widgets.dart';
import '../../points/widgets/point_balance.dart';

class HomePointsHeader extends StatelessWidget {
  const HomePointsHeader({super.key});

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
                child: RewardCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 22,
                  ),
                  border: Border.all(color: const Color(0xFF70DC9A)),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All points are active.',
                              style: TextStyle(
                                color: Color(0xFF00B83E),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              'None expiring in the next 30 days.',
                              style: TextStyle(
                                color: AppTheme.muted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFDCFCE7),
                        child: Icon(Icons.task_alt, color: Color(0xFF00B83E)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
