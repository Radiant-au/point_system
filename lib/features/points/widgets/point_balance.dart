import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/points_provider.dart';

class PointBalance extends ConsumerWidget {
  const PointBalance({super.key, this.onBlue = false});
  final bool onBlue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(pointsProvider);
    final color = onBlue ? Colors.white : AppTheme.blue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: onBlue
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                balance.value?.toString() ?? '—',
                key: Key(
                  onBlue ? 'home-point-balance' : 'member-point-balance',
                ),
                style: TextStyle(
                  color: color,
                  fontSize: onBlue ? 48 : 24,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                tooltip: 'Refresh points',
                style: IconButton.styleFrom(
                  backgroundColor: onBlue
                      ? Colors.white.withValues(alpha: .2)
                      : AppTheme.field,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: balance.isLoading
                    ? null
                    : () => ref.read(pointsProvider.notifier).refresh(),
                icon: balance.isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      )
                    : Icon(Icons.refresh_rounded, size: 20, color: color),
              ),
            ),
          ],
        ),
        if (balance.hasError)
          Text(
            'Could not refresh points. Tap refresh to retry.',
            style: TextStyle(color: color, fontSize: 11),
          ),
      ],
    );
  }
}
