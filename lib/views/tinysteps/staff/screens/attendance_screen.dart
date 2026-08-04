import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/providers/attendance_provider.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(attendanceProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);

    final presentCount = state.attendance.values
        .where((a) => a != null && a.isCheckedIn)
        .length;
    final total = state.children.length;

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Attendance', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/teacher'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(attendanceProvider.notifier).loadData(),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: state.loading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : state.error != null
          ? _buildError(context, state.error!)
          : state.children.isEmpty
          ? _buildEmpty(context)
          : _buildList(context, state, presentCount, total),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: context.colors.danger,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Something went wrong', style: context.textStyles.heading2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: context.textStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => ref.read(attendanceProvider.notifier).loadData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 72,
              color: context.colors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No children assigned', style: context.textStyles.heading2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No children are assigned to your classroom yet.\nAsk the admin to assign children.',
              style: context.textStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    dynamic state,
    int presentCount,
    int total,
  ) {
    final today = _formatDateToday();

    return Column(
      children: [
        // ── Summary bar ───────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: context.colors.primaryLight.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Row(
            children: [
              Icon(
                Icons.today_rounded,
                color: context.colors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                today,
                style: context.textStyles.labelMedium.copyWith(
                  color: context.colors.primaryDark,
                ),
              ),
              const Spacer(),
              Text(
                '$presentCount / $total present',
                style: context.textStyles.labelBold.copyWith(
                  color: context.colors.primaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Child list ────────────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            itemCount: state.children.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) =>
                _buildChildTile(context, state.children[i], state),
          ),
        ),
      ],
    );
  }

  String _formatDateToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Widget _buildChildTile(
    BuildContext context,
    Map<String, dynamic> child,
    dynamic state,
  ) {
    final childId = child['id'] as String;
    final name = child['full_name'] as String? ?? 'Unknown';
    final att = state.attendance[childId];
    final isSaving = state.saving[childId] == true;

    final checkedIn = att != null && att.isCheckedIn;
    final checkedOut = att != null && att.isCheckedOut;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (checkedOut) {
      statusColor = context.colors.textMuted;
      statusLabel = 'Out ${_formatTime(att.checkedOutAt)}';
      statusIcon = Icons.logout_rounded;
    } else if (checkedIn) {
      statusColor = context.colors.success;
      statusLabel = 'In ${_formatTime(att.checkedInAt)}';
      statusIcon = Icons.login_rounded;
    } else {
      statusColor = context.colors.textMuted;
      statusLabel = 'Not marked';
      statusIcon = Icons.radio_button_unchecked;
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: checkedIn && !checkedOut
              ? context.colors.success.withValues(alpha: 0.4)
              : context.colors.border.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: checkedIn
              ? context.colors.success.withValues(alpha: 0.15)
              : context.colors.primaryLight.withValues(alpha: 0.4),
          child: Text(
            name[0].toUpperCase(),
            style: context.textStyles.labelBold.copyWith(
              color: checkedIn
                  ? context.colors.success
                  : context.colors.primaryDark,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(name, style: context.textStyles.labelBold),
        subtitle: Row(
          children: [
            Icon(statusIcon, size: 13, color: statusColor),
            const SizedBox(width: 4),
            Text(
              statusLabel,
              style: context.textStyles.caption.copyWith(color: statusColor),
            ),
          ],
        ),
        trailing: isSaving
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.primary,
                ),
              )
            : _buildActionButton(context, childId, checkedIn, checkedOut),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String childId,
    bool checkedIn,
    bool checkedOut,
  ) {
    if (!checkedIn) {
      // Not yet marked — show Check In button
      return FilledButton(
        onPressed: () => ref.read(attendanceProvider.notifier).checkIn(childId),
        style: FilledButton.styleFrom(
          backgroundColor: context.colors.success,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          'Check In',
          style: context.textStyles.labelMedium.copyWith(color: Colors.white),
        ),
      );
    }

    if (!checkedOut) {
      // Checked in but not out — show Check Out and Undo buttons
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () =>
                ref.read(attendanceProvider.notifier).checkOut(childId),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.secondary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(
              'Check Out',
              style: context.textStyles.labelSmall.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: () =>
                ref.read(attendanceProvider.notifier).undo(childId),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colors.danger),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(
              'Undo',
              style: context.textStyles.labelSmall.copyWith(
                color: context.colors.danger,
              ),
            ),
          ),
        ],
      );
    }

    // Checked out — show Undo button only
    return OutlinedButton(
      onPressed: () => ref.read(attendanceProvider.notifier).undo(childId),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: context.colors.warning),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Text(
        'Undo',
        style: context.textStyles.labelMedium.copyWith(
          color: context.colors.warning,
        ),
      ),
    );
  }

  String _formatTime(String? isoUtc) {
    if (isoUtc == null) return '';
    try {
      final dt = DateTime.parse(isoUtc).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
