import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../history/screens/history_screen.dart';
import '../../member/screens/member_card_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../rewards/screens/rewards_screen.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/home_content.dart';
import '../widgets/home_points_header.dart';

// This shell keeps the bottom navigation visible while switching pages.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  void _openMemberCard() => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const MemberCardScreen()));

  void _selectTab(int index) {
    if (index == 4) {
      _openMemberCard();
    } else {
      setState(() => _selectedTab = index);
    }
  }

  void _goHome() => _selectTab(0);

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: _selectedTab == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && _selectedTab != 0) _goHome();
    },
    child: Scaffold(
      backgroundColor: AppTheme.canvas,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedTab,
            children: [
              CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: HomePointsHeader()),
                  SliverToBoxAdapter(
                    child: HomeContent(onOpenMemberCard: _openMemberCard),
                  ),
                ],
              ),
              RewardsScreen(onBack: _goHome),
              HistoryScreen(onBack: _goHome),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: _selectedTab,
        onSelected: _selectTab,
      ),
    ),
  );
}
