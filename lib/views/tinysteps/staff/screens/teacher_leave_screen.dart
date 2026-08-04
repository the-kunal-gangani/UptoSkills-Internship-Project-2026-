import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/Controllers/teacher_leave_controller.dart';
import 'package:tinysteps/Models/teacher_leave_model.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Teacher Leave Screen
// Staff side: apply for leave/holidays, view upcoming and past leaves
// ─────────────────────────────────────────────────────────────────────────────
class TeacherLeaveScreen extends ConsumerStatefulWidget {
  const TeacherLeaveScreen({super.key});

  @override
  ConsumerState<TeacherLeaveScreen> createState() =>
      _TeacherLeaveScreenState();
}

class _TeacherLeaveScreenState extends ConsumerState<TeacherLeaveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showApplyLeaveSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplyLeaveSheet(
        onApply: ({
          required DateTime date,
          required String reason,
          required String leaveType,
        }) async {
          final ok = await ref.read(teacherLeaveProvider.notifier).applyLeave(
                leaveDate: date,
                reason: reason,
                leaveType: leaveType,
              );

          if (!mounted) return;
          Navigator.pop(context);

          if (ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Leave applied successfully!'),
                backgroundColor: context.colors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            );
          } else {
            final error = ref.read(teacherLeaveProvider).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? 'Failed to apply leave.'),
                backgroundColor: context.colors.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _cancelLeave(TeacherLeaveModel leave) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text('Cancel Leave', style: context.textStyles.heading3),
        content: Text(
          'Are you sure you want to cancel the leave on ${leave.formattedDate}?',
          style: context.textStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No',
                style: context.textStyles.labelBold
                    .copyWith(color: context.colors.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Yes, Cancel',
                style: context.textStyles.buttonLabel),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok =
        await ref.read(teacherLeaveProvider.notifier).cancelLeave(leave.id);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Leave cancelled.'),
          backgroundColor: context.colors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherLeaveProvider);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Leave & Holidays', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(teacherLeaveProvider.notifier).loadLeaves(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.colors.primary,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textMuted,
          labelStyle: context.textStyles.labelBold,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyLeaveSheet,
        backgroundColor: context.colors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Apply Leave',
            style: context.textStyles.buttonLabel
                .copyWith(color: Colors.white)),
      ),
      body: state.isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: context.colors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                // ── Upcoming leaves ────────────────────────────────────────
                _LeaveList(
                  leaves: state.upcomingLeaves,
                  emptyMessage: 'No upcoming leaves.\nTap + to apply for leave.',
                  canCancel: true,
                  onCancel: _cancelLeave,
                ),

                // ── Past leaves ────────────────────────────────────────────
                _LeaveList(
                  leaves: state.pastLeaves,
                  emptyMessage: 'No past leaves recorded.',
                  canCancel: false,
                  onCancel: null,
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leave List
// ─────────────────────────────────────────────────────────────────────────────
class _LeaveList extends StatelessWidget {
  final List<TeacherLeaveModel> leaves;
  final String emptyMessage;
  final bool canCancel;
  final Future<void> Function(TeacherLeaveModel)? onCancel;

  const _LeaveList({
    required this.leaves,
    required this.emptyMessage,
    required this.canCancel,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded,
                size: 64, color: context.colors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMuted,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
      itemCount: leaves.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final leave = leaves[index];
        return _LeaveCard(
          leave: leave,
          canCancel: canCancel,
          onCancel: onCancel != null ? () => onCancel!(leave) : null,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leave Card
// ─────────────────────────────────────────────────────────────────────────────
class _LeaveCard extends StatelessWidget {
  final TeacherLeaveModel leave;
  final bool canCancel;
  final VoidCallback? onCancel;

  const _LeaveCard({
    required this.leave,
    required this.canCancel,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isHoliday = leave.isHoliday;
    final color = isHoliday ? context.colors.secondary : context.colors.warning;
    final bgColor = isHoliday
        ? context.colors.secondaryLight
        : context.colors.warningLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${leave.leaveDate.day}',
                  style: context.textStyles.heading3
                      .copyWith(color: color, height: 1),
                ),
                Text(
                  _monthAbbr(leave.leaveDate.month),
                  style: context.textStyles.caption
                      .copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                            color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        isHoliday ? '🎉 Holiday' : '🏖️ Leave',
                        style: context.textStyles.caption
                            .copyWith(color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  leave.reason.isEmpty ? 'No reason provided' : leave.reason,
                  style: context.textStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  leave.formattedDate,
                  style: context.textStyles.caption,
                ),
              ],
            ),
          ),

          // Cancel button (upcoming only)
          if (canCancel && onCancel != null)
            IconButton(
              icon: Icon(Icons.close_rounded,
                  color: context.colors.danger, size: 20),
              onPressed: onCancel,
              tooltip: 'Cancel leave',
            ),
        ],
      ),
    );
  }

  static String _monthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Apply Leave Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ApplyLeaveSheet extends ConsumerStatefulWidget {
  final Future<void> Function({
    required DateTime date,
    required String reason,
    required String leaveType,
  }) onApply;

  const _ApplyLeaveSheet({required this.onApply});

  @override
  ConsumerState<_ApplyLeaveSheet> createState() =>
      _ApplyLeaveSheetState();
}

class _ApplyLeaveSheetState extends ConsumerState<_ApplyLeaveSheet> {
  DateTime? _selectedDate;
  String _leaveType = 'leave';
  final _reasonCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: context.colors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a date.'),
          backgroundColor: context.colors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide a reason.'),
          backgroundColor: context.colors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await widget.onApply(
      date: _selectedDate!,
      reason: _reasonCtrl.text.trim(),
      leaveType: _leaveType,
    );
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
          AppSpacing.lg + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Apply for Leave', style: context.textStyles.heading3),
          const SizedBox(height: AppSpacing.xs),
          Text('Select the date and reason for your leave.',
              style: context.textStyles.bodyMuted),
          const SizedBox(height: AppSpacing.lg),

          // Leave Type
          Row(
            children: [
              Expanded(
                child: _TypeToggle(
                  label: '🏖️  Leave',
                  value: 'leave',
                  selected: _leaveType,
                  onTap: () => setState(() => _leaveType = 'leave'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _TypeToggle(
                  label: '🎉  Holiday',
                  value: 'holiday',
                  selected: _leaveType,
                  onTap: () => setState(() => _leaveType = 'holiday'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Date picker
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.bgMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: _selectedDate != null
                      ? context.colors.primary
                      : context.colors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: context.colors.primary, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? _fmtDate(_selectedDate!)
                          : 'Select date',
                      style: _selectedDate != null
                          ? context.textStyles.labelBold
                          : context.textStyles.bodyMuted,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: context.colors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Reason field
          TextFormField(
            controller: _reasonCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Reason',
              hintText: 'e.g. Medical appointment, family event...',
              filled: true,
              fillColor: context.colors.bgMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: context.colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: context.colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                    color: context.colors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Apply Leave',
                      style: context.textStyles.buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.bgMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textStyles.labelBold.copyWith(
              color: isSelected
                  ? context.colors.primary
                  : context.colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
