import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final item in const [
                      (Icons.home_outlined, 'Home'),
                      (Icons.card_giftcard_outlined, 'Rewards'),
                    ])
                      Expanded(
                        child: _NavItem(
                          icon: item.$1,
                          label: item.$2,
                          selected:
                              selectedIndex == (item.$2 == 'Home' ? 0 : 1),
                          onTap: () => onSelected(item.$2 == 'Home' ? 0 : 1),
                        ),
                      ),
                    const SizedBox(width: 52),
                    for (final item in const [
                      (Icons.sync_rounded, 'History'),
                      (Icons.person_outline, 'Profile'),
                    ])
                      Expanded(
                        child: _NavItem(
                          icon: item.$1,
                          label: item.$2,
                          selected:
                              selectedIndex == (item.$2 == 'History' ? 2 : 3),
                          onTap: () => onSelected(item.$2 == 'History' ? 2 : 3),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: (constraints.maxWidth - 52) / 2,
                top: -14,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppTheme.blue,
                      shape: const CircleBorder(),
                      elevation: 4,
                    ),
                    onPressed: () => onSelected(4),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.blue : const Color(0xFF99A1AF);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, height: 1),
          ),
        ],
      ),
    );
  }
}
