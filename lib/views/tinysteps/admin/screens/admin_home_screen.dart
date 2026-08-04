import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/controllers/admin_dashboard_controller.dart';
import 'package:tinysteps/controllers/alert_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/core/widgets/active_alert_dialog.dart';
import 'package:tinysteps/core/widgets/bottom_nav_bar.dart';
import 'package:tinysteps/views/tinysteps/admin/screens/admin_settings_screen.dart';
import 'package:tinysteps/views/tinysteps/admin/screens/children_overview_screen.dart';
import 'package:tinysteps/views/tinysteps/admin/screens/classrooms_screen.dart';
import 'package:tinysteps/views/tinysteps/admin/screens/referral_codes_screen.dart';
import 'package:tinysteps/views/tinysteps/admin/screens/sessions_screen.dart';
import 'package:tinysteps/views/tinysteps/admin/screens/users_screen.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = [
    const _AdminDashboardTab(),
    const UsersScreen(),
    const ReferralCodesScreen(),
    const ClassroomsScreen(),
    const ChildrenOverviewScreen(),
    const SessionsScreen(),
    const AdminSettingsScreen(),
  ];

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
        body: IndexedStack(index: _currentIndex, children: _tabs),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavBarItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
            BottomNavBarItem(icon: Icons.people_rounded, label: 'Users'),
            BottomNavBarItem(icon: Icons.vpn_key_rounded, label: 'Referrals'),
            BottomNavBarItem(icon: Icons.class_rounded, label: 'Groups'),
            BottomNavBarItem(icon: Icons.child_care_rounded, label: 'Children'),
            BottomNavBarItem(icon: Icons.event_note_rounded, label: 'Sessions'),
            BottomNavBarItem(icon: Icons.settings_rounded, label: 'Settings'),
          ],
        ),
      ),
    );
  }

  void switchTab(int index) => setState(() => _currentIndex = index);
}

// ── Dashboard tab ─────────────────────────────────────────────────────────────
class _AdminDashboardTab extends ConsumerWidget {
  const _AdminDashboardTab();

  Future<void> _confirmSignOut(
    BuildContext context,
    AdminDashboardController ctrl,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgLight,
        surfaceTintColor: Colors.transparent,
        title: Text('Sign out?', style: context.textStyles.heading3),
        content: Text(
          'You will be returned to the login screen.',
          style: context.textStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: context.textStyles.labelBold.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign out', style: context.textStyles.buttonLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) await ctrl.signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardProvider);
    final ctrl = ref.read(adminDashboardProvider.notifier);

    // Find the parent AdminHomeScreen state to switch tabs
    final homeState = context.findAncestorStateOfType<_AdminHomeScreenState>();

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Admin Panel', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context, ctrl),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: ctrl.loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl + 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting card ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppGradients.sunrise,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      ctrl.greeting,
                      style: context.textStyles.bodyLarge.copyWith(
                        color: context.colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ctrl.adminName,
                      style: context.textStyles.heading1.copyWith(
                        color: context.colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              Text(
                'Here\'s your daycare at a glance',
                style: context.textStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Stats grid ────────────────────────────────────────
              if (state.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        _StatCard(
                          label: 'Staff',
                          value: '${state.stats['teachers']}',
                          icon: Icons.badge_rounded,
                          color: context.colors.primary,
                          onTap: () => homeState?.switchTab(1),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _StatCard(
                          label: 'Pending Approval',
                          value: '${state.stats['pendingTeachers']}',
                          icon: Icons.pending_actions,
                          color: context.colors.warning,
                          onTap: () => homeState?.switchTab(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Parents',
                          value: '${state.stats['parents']}',
                          icon: Icons.family_restroom,
                          color: context.colors.secondary,
                          onTap: () => homeState?.switchTab(1),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _StatCard(
                          label: 'Children',
                          value: '${state.stats['children']}',
                          icon: Icons.child_care,
                          color: context.colors.accent,
                          onTap: () => homeState?.switchTab(3),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Groups',
                          value: '${state.stats['classrooms']}',
                          icon: Icons.group_rounded,
                          color: context.colors.success,
                          onTap: () => homeState?.switchTab(2),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _StatCard(
                          label: 'Sessions',
                          value: '•••',
                          icon: Icons.event_note_rounded,
                          color: context.colors.accent,
                          onTap: () => homeState?.switchTab(4),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _StatCard(
                          label: 'Referral Codes',
                          value: 'Manage',
                          icon: Icons.vpn_key_rounded,
                          color: context.colors.secondary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReferralCodesScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final VoidCallback? onTap;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: context.textStyles.heading1.copyWith(color: color),
              ),
              Text(label, style: context.textStyles.bodyMuted),
            ],
          ),
        ),
      ),
    );
  }
}
