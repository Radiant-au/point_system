import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/rewards_provider.dart';
import '../../../core/widgets/rewards_load_state.dart';

import '../../../core/theme/app_theme.dart';
import '../../expiry/screens/expiry_details_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../member/screens/member_card_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../rewards/screens/rewards_screen.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/home_content.dart';
import '../widgets/home_points_header.dart';

// This shell keeps the bottom navigation visible while switching pages.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;
  bool _showExpiry = false;

  void _openExpiry() => setState(() {
    _selectedTab = 0;
    _showExpiry = true;
  });

  void _openMemberCard() => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const MemberCardScreen()));

  void _selectTab(int index) {
    if (index == 4) {
      _openMemberCard();
    } else {
      setState(() {
        _selectedTab = index;
        _showExpiry = false;
      });
    }
  }

  void _goHome() => _selectTab(0);

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: _selectedTab == 0 && !_showExpiry,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && (_selectedTab != 0 || _showExpiry)) _goHome();
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
          child: ref.watch(rewardsProvider).hasValue
              ? IndexedStack(
                  index: _showExpiry ? 4 : _selectedTab,
                  children: [
                    CustomScrollView(
                      slivers: [
                        if (ref.watch(rewardsProvider).value?.usingSavedData ??
                            false)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Showing saved rewards. Tap refresh to try again.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: HomePointsHeader(onOpenExpiry: _openExpiry),
                        ),
                        SliverToBoxAdapter(
                          child: HomeContent(onOpenMemberCard: _openMemberCard),
                        ),
                      ],
                    ),
                    RewardsScreen(onBack: _goHome),
                    HistoryScreen(onBack: _goHome),
                    const ProfileScreen(),
                    ExpiryDetailsScreen(onBack: _goHome),
                  ],
                )
              : const RewardsLoadState(),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: _selectedTab,
        onSelected: _selectTab,
      ),
    ),
  );
}
