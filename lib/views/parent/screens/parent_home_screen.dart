import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/controllers/alert_controller.dart';
import 'package:tinysteps/core/widgets/active_alert_dialog.dart';
import 'package:tinysteps/core/widgets/bottom_nav_bar.dart';
import 'package:tinysteps/views/parent/screens/analytics_screen.dart';
import 'package:tinysteps/views/parent/screens/feed_screen.dart';
import 'package:tinysteps/views/parent/screens/parent_profile_screen.dart';
import 'package:tinysteps/views/parent/screens/safety_screen.dart';
import 'package:tinysteps/views/parent/screens/my_sessions_screen.dart';

class ParentHomeScreen extends ConsumerStatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  ConsumerState<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends ConsumerState<ParentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    SafetyScreen(),
    MySessionsScreen(),
    AnalyticsScreen(),
    ParentProfileScreen(),
  ];

  void switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    // Realtime Emergency Listener
    ref.listen<AlertState>(alertMonitorProvider, (previous, next) {
      if (next.activeAlert != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => ActiveAlertDialog(alert: next.activeAlert!),
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {

        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavBarItem(icon: Icons.assignment_rounded, label: 'Feed'),
            BottomNavBarItem(icon: Icons.videocam_rounded, label: 'Safety'),
            BottomNavBarItem(icon: Icons.event_note_rounded, label: 'Sessions'),
            BottomNavBarItem(icon: Icons.insights_rounded, label: 'Analytics'),
            BottomNavBarItem(icon: Icons.person_rounded, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}