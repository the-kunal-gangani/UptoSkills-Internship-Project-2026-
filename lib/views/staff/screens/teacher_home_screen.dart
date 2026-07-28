import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tinysteps/controllers/teacher_home_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/core/widgets/app_calendar.dart';
import 'package:tinysteps/core/widgets/bottom_nav_bar.dart';
import 'package:tinysteps/core/widgets/logout_dialog.dart';
import 'package:tinysteps/Views/staff/screens/teacher_settings_screen.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const _TeacherDashboardTab(),
    const _TeacherAttendanceTab(),
    const _TeacherChildrenTab(),
    const TeacherSettingsScreen(),
  ];

  void switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherHomeProvider);

    // Still checking approval
    if (state.isApproved == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
      );
    }

    // Not approved — show gate
    if (state.isApproved == false) {
      final ctrl = ref.read(teacherHomeProvider.notifier);
      return _PendingApprovalScreen(
        onRefresh: ctrl.checkApproval,
        onSignOut: ctrl.signOut,
      );
    }

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
            BottomNavBarItem(icon: Icons.home_rounded, label: 'Home'),
            BottomNavBarItem(
              icon: Icons.assignment_rounded,
              label: 'Attendance',
            ),
            BottomNavBarItem(icon: Icons.face_rounded, label: 'Children'),
            BottomNavBarItem(icon: Icons.settings_rounded, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

// ── Pending approval gate ─────────────────────────────────────────────────────
class _PendingApprovalScreen extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function() onSignOut;

  const _PendingApprovalScreen({
    required this.onRefresh,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('TinySteps', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: onSignOut,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: context.colors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 72,
                  color: context.colors.warning,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Pending Approval', style: context.textStyles.heading1),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your account is waiting for admin approval.\n'
                'You\'ll be able to access the dashboard\nonce an admin approves your account.',
                style: context.textStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    side: BorderSide(color: context.colors.primary),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
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

// ── Dashboard tab ─────────────────────────────────────────────────────────────
class _TeacherDashboardTab extends ConsumerWidget {
  const _TeacherDashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherHomeProvider);
    final ctrl = ref.read(teacherHomeProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('TinySteps', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirmed = await showLogoutDialog(context);
              if (confirmed) await ctrl.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.loadTodayAttendance,
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
              Text(
                'Good day, ${ctrl.teacherName}',
                style: context.textStyles.heading1,
              ),
              Text(
                'Ready to take attendance?',
                style: context.textStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/teacher/attendance'),
                  icon: Icon(
                    Icons.how_to_reg_rounded,
                    color: context.colors.white,
                  ),
                  label: Text(
                    'Mark Attendance',
                    style: context.textStyles.buttonLabel,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              Text('Calendar', style: context.textStyles.heading2),
              const SizedBox(height: AppSpacing.md),
              const AppCalendar(),
              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Attendance',
                    style: context.textStyles.heading2,
                  ),
                  Text(
                    DateFormat('dd MMM').format(DateTime.now()),
                    style: context.textStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Attendance summary
              if (state.isLoadingAttendance)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                )
              else if (state.todayAttendance.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: context.colors.primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No attendance marked yet today',
                        style: context.textStyles.bodyMuted,
                      ),
                      Text(
                        'Tap "Mark Attendance" above to get started',
                        style: context.textStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: state.todayAttendance.map((r) {
                    final row = r as Map<String, dynamic>;
                    final child =
                        row['children'] as Map<String, dynamic>? ?? {};
                    final name = child['full_name'] as String? ?? 'Child';
                    final checkIn = ctrl.formatTime(
                      row['checked_in_at'] as String?,
                    );
                    final checkOut = row['checked_out_at'] != null
                        ? ctrl.formatTime(row['checked_out_at'] as String?)
                        : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () {
                          final id = row['child_id']?.toString() ?? '';
                          if (id.isNotEmpty) {
                            context.push(
                              '/teacher/child/$id?name=${Uri.encodeComponent(name)}',
                            );
                          }
                        },
                        child: _AttendanceTile(
                          name: name,
                          checkIn: checkIn,
                          checkOut: checkOut,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Attendance tab ────────────────────────────────────────────────────────────
class _TeacherAttendanceTab extends ConsumerWidget {
  const _TeacherAttendanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Attendance', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: context.colors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.how_to_reg_rounded,
                size: 80,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Manual Attendance', style: context.textStyles.heading2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Mark each child as checked in or checked out '
              'for today. Timestamps are recorded automatically.',
              style: context.textStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/teacher/attendance'),
                icon: const Icon(Icons.assignment_turned_in_rounded),
                label: Text(
                  'Open Attendance List',
                  style: context.textStyles.buttonLabel,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Children tab ──────────────────────────────────────────────────────────────
class _TeacherChildrenTab extends ConsumerWidget {
  const _TeacherChildrenTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teacherHomeProvider);
    final ctrl = ref.read(teacherHomeProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('My Children', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'My Schedule',
            onPressed: () => context.push('/teacher/schedule'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'My Groups',
            onPressed: () => context.push('/teacher/classroom'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: ctrl.loadChildren,
        child: state.isLoadingChildren
            ? Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              )
            : state.children.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.face_outlined,
                        size: 64,
                        color: context.colors.primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No children assigned yet',
                        style: context.textStyles.heading3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Admin will assign children to you\nonce they book a session.',
                        style: context.textStyles.bodyMuted,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: state.children.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final c = state.children[index] as Map<String, dynamic>;
                  final status = c['status'] as String? ?? 'active';
                  final dob = c['date_of_birth'] as String?;
                  final age = dob != null ? ctrl.calcAge(dob) : null;
                  final nameStr = c['full_name'] as String? ?? 'Child';
                  return GestureDetector(
                    onTap: () {
                      final id = c['id']?.toString() ?? '';
                      if (id.isNotEmpty) {
                        context.push(
                          '/teacher/child/$id?name=${Uri.encodeComponent(nameStr)}',
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.colors.bgSurface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: context.colors.border),
                        boxShadow: AppShadows.card,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: context.colors.primaryLight,
                            child: Text(
                              nameStr.isNotEmpty
                                  ? nameStr[0].toUpperCase()
                                  : 'C',
                              style: context.textStyles.heading3.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nameStr,
                                  style: context.textStyles.labelBold,
                                ),
                                if (age != null)
                                  Text(
                                    age,
                                    style: context.textStyles.bodySmall,
                                  ),
                                if (c['allergies'] != null &&
                                    (c['allergies'] as String).isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber,
                                        size: 12,
                                        color: context.colors.warning,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          c['allergies'] as String,
                                          style: context.textStyles.caption
                                              .copyWith(
                                                color: context.colors.warning,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          _statusBadge(context, status),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final color = switch (status) {
      'checked_in' => context.colors.success,
      'checked_out' => context.colors.textMuted,
      _ => context.colors.secondary,
    };
    final label = switch (status) {
      'checked_in' => 'In Class',
      'checked_out' => 'Picked Up',
      _ => 'Enrolled',
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: context.textStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Attendance tile ───────────────────────────────────────────────────────────
class _AttendanceTile extends StatelessWidget {
  final String name;
  final String checkIn;
  final String? checkOut;

  const _AttendanceTile({
    required this.name,
    required this.checkIn,
    this.checkOut,
  });

  @override
  Widget build(BuildContext context) {
    final isOut = checkOut != null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.colors.primaryLight,
            child: Text(
              name[0].toUpperCase(),
              style: context.textStyles.labelBold.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: context.textStyles.labelBold),
                Text(
                  isOut
                      ? 'In: $checkIn  ·  Out: $checkOut'
                      : 'Checked in at $checkIn',
                  style: context.textStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isOut
                  ? context.colors.textMuted.withValues(alpha: 0.1)
                  : context.colors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              isOut ? 'Picked Up' : 'In Class',
              style: context.textStyles.caption.copyWith(
                color: isOut
                    ? context.colors.textMuted
                    : context.colors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
