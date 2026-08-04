import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/Controllers/parent_attendance_controller.dart';
import 'package:tinysteps/Views/tinysteps/parent/widgets/attendance_card.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentAttendanceProvider);
    final ctrl = ref.read(parentAttendanceProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Attendance', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: ctrl.loadAttendance,
        child: _buildBody(context, state, ctrl),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ParentAttendanceState state,
    ParentAttendanceController ctrl,
  ) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          'Failed to load attendance.\nPull down to retry.',
          style: context.textStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: context.colors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No attendance records yet.',
              style: context.textStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Records will appear here once a caregiver\nmarks your child\'s session as started.',
              style: context.textStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.records.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final r = state.records[index] as Map<String, dynamic>;
        final childData = r['children'] as Map<String, dynamic>? ?? {};
        final childName = childData['full_name'] as String? ?? 'Child';

        return AttendanceCard(
          childName: childName,
          date: ctrl.formatDate(r['date'] as String?),
          checkIn: ctrl.formatTime(r['checked_in_at'] as String?),
          checkOut: ctrl.formatTime(r['checked_out_at'] as String?),
          method: r['method'] as String? ?? 'manual',
        );
      },
    );
  }
}
