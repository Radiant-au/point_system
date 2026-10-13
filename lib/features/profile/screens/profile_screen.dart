import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/reward_widgets.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/reset_password_screen.dart';
import '../../member/providers/member_provider.dart';
import '../../expiry/providers/expiry_provider.dart';
import '../../points/providers/points_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(memberProvider);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          decoration: const BoxDecoration(gradient: AppTheme.blueGradient),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  member.name.isEmpty ? '?' : member.name.substring(0, 1),
                  style: const TextStyle(
                    color: AppTheme.blue,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                member.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                member.phone,
                style: const TextStyle(color: Color(0xFFD2E3FF), fontSize: 12),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RewardCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF9810FA),
                    ),
                  ),
                  title: const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Password & authentication',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF99A1AF),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ResetPasswordScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              RewardCard(
                padding: EdgeInsets.zero,
                border: Border.all(color: const Color(0xFFFFE2E2)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE2E2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.logout, color: Colors.red),
                  ),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  onTap: () {
                    ref.invalidate(pointsProvider);
                    ref.invalidate(expiryGroupsProvider);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                      (_) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
