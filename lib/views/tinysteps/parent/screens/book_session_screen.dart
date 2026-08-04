import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/Controllers/booking_session_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Book Session Screen (enhanced with teacher availability validation)
// Parent side: select child → pick date → pick available teacher & slot → confirm
// ─────────────────────────────────────────────────────────────────────────────
class BookSessionScreen extends ConsumerStatefulWidget {
  const BookSessionScreen({super.key});

  @override
  ConsumerState<BookSessionScreen> createState() => _BookSessionScreenState();
}

class _BookSessionScreenState extends ConsumerState<BookSessionScreen> {
  int _step = 0;

  // Form state
  String? _selectedChildId;
  String? _selectedChildName;
  DateTime? _selectedDate;
  AvailableTeacher? _selectedTeacher;
  String? _selectedStartTime;
  String? _selectedEndTime;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Step validation ──────────────────────────────────────────────────────
  bool get _step0Valid => _selectedChildId != null;
  bool get _step1Valid =>
      _selectedDate != null &&
      _selectedTeacher != null &&
      _selectedStartTime != null &&
      _selectedEndTime != null;

  // ── Navigation ───────────────────────────────────────────────────────────
  void _nextStep() {
    if (_step == 1 && _selectedDate != null) {
      // Load available teachers when moving past step 1
      ref
          .read(bookingSessionProvider.notifier)
          .loadAvailableTeachers(_selectedDate!);
    }
    setState(() => _step++);
  }

  void _prevStep() => setState(() => _step--);

  // ── Submit booking ───────────────────────────────────────────────────────
  Future<void> _submit() async {
    final ctrl = ref.read(bookingSessionProvider.notifier);
    final booking = await ctrl.createBooking(
      teacherId: _selectedTeacher!.id,
      childId: _selectedChildId!,
      date: _selectedDate!,
      startTime: _selectedStartTime!,
      endTime: _selectedEndTime!,
      notes: _notesCtrl.text,
    );

    if (!mounted) return;

    if (booking != null) {
      context.push('/parent/booking-confirmation', extra: booking);
    } else {
      final error = ref.read(bookingSessionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Booking failed. Please try again.'),
          backgroundColor: context.colors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingSessionProvider);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Book a Session', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
      ),
      body: Column(
        children: [
          _StepIndicator(current: _step, total: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _buildStep(state),
            ),
          ),
          _BottomNav(
            step: _step,
            canNext: _step == 0
                ? _step0Valid
                : _step == 1
                    ? _step1Valid
                    : true,
            isSaving: state.isSaving,
            onBack: _step == 0 ? null : _prevStep,
            onNext: _step < 2 ? _nextStep : _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BookingSessionState state) {
    return switch (_step) {
      0 => _StepSelectChild(
          children: state.myChildren,
          selectedId: _selectedChildId,
          onSelect: (id, name) =>
              setState(() {
                _selectedChildId = id;
                _selectedChildName = name;
              }),
        ),
      1 => _StepPickDateTime(
          selectedDate: _selectedDate,
          onDatePick: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: Theme.of(ctx)
                      .colorScheme
                      .copyWith(primary: context.colors.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                // Reset teacher & time when date changes
                _selectedTeacher = null;
                _selectedStartTime = null;
                _selectedEndTime = null;
              });
              await ref
                  .read(bookingSessionProvider.notifier)
                  .loadAvailableTeachers(picked);
            }
          },
          availableTeachers: state.availableTeachers,
          isLoadingTeachers: state.isLoadingTeachers,
          selectedTeacher: _selectedTeacher,
          selectedStartTime: _selectedStartTime,
          onSelectTeacher: (teacher) {
            setState(() {
              _selectedTeacher = teacher;
              _selectedStartTime = null;
              _selectedEndTime = null;
            });
          },
          onSelectSlot: (start, end) => setState(() {
                _selectedStartTime = start;
                _selectedEndTime = end;
              }),
        ),
      _ => _StepReview(
          childName: _selectedChildName ?? '',
          teacher: _selectedTeacher,
          date: _selectedDate,
          startTime: _selectedStartTime,
          endTime: _selectedEndTime,
          notesCtrl: _notesCtrl,
        ),
    };
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Step 0 – Select Child
// ─────────────────────────────────────────────────────────────────────────────
class _StepSelectChild extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final String? selectedId;
  final void Function(String id, String name) onSelect;

  const _StepSelectChild({
    required this.children,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Child', style: context.textStyles.heading3),
        const SizedBox(height: 4),
        Text('Choose the child for this session.',
            style: context.textStyles.bodyMuted),
        const SizedBox(height: AppSpacing.lg),
        if (children.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(Icons.face_rounded,
                    size: 64, color: context.colors.textMuted),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No children found.\nAdd a child profile first.',
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMuted,
                ),
              ],
            ),
          )
        else
          ...children.map((c) {
            final id = c['id'] as String;
            final name = c['full_name'] as String? ?? 'Child';
            final isSelected = selectedId == id;
            return GestureDetector(
              onTap: () => onSelect(id, name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary.withValues(alpha: 0.08)
                      : context.colors.bgSurface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isSelected
                          ? context.colors.primary
                          : context.colors.primaryLight,
                      child: Text(
                        name[0].toUpperCase(),
                        style: context.textStyles.labelBold.copyWith(
                          color: isSelected
                              ? context.colors.white
                              : context.colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: Text(name,
                            style: context.textStyles.labelBold)),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          color: context.colors.primary, size: 22),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 – Pick Date, Teacher & Time Slot
// ─────────────────────────────────────────────────────────────────────────────
class _StepPickDateTime extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onDatePick;
  final List<AvailableTeacher> availableTeachers;
  final bool isLoadingTeachers;
  final AvailableTeacher? selectedTeacher;
  final String? selectedStartTime;
  final void Function(AvailableTeacher) onSelectTeacher;
  final void Function(String start, String end) onSelectSlot;

  const _StepPickDateTime({
    required this.selectedDate,
    required this.onDatePick,
    required this.availableTeachers,
    required this.isLoadingTeachers,
    required this.selectedTeacher,
    required this.selectedStartTime,
    required this.onSelectTeacher,
    required this.onSelectSlot,
  });

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date & Teacher', style: context.textStyles.heading3),
        const SizedBox(height: 4),
        Text('Pick a date to see available teachers.',
            style: context.textStyles.bodyMuted),
        const SizedBox(height: AppSpacing.lg),

        // Date picker tile
        GestureDetector(
          onTap: onDatePick,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.bgSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: selectedDate != null
                    ? context.colors.primary
                    : context.colors.border,
                width: selectedDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.calendar_today_rounded,
                      color: context.colors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session Date',
                          style: context.textStyles.caption),
                      Text(
                        selectedDate != null
                            ? _fmtDate(selectedDate!)
                            : 'Tap to choose',
                        style: selectedDate != null
                            ? context.textStyles.labelBold
                            : context.textStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: context.colors.textMuted),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Available teachers
        if (selectedDate != null) ...[
          Text('Available Teachers', style: context.textStyles.labelBold),
          const SizedBox(height: AppSpacing.sm),
          if (isLoadingTeachers)
            const Center(child: CircularProgressIndicator())
          else if (availableTeachers.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.colors.warningLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: context.colors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: context.colors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'No teachers available on this date.\nPlease try a different date.',
                      style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.warning),
                    ),
                  ),
                ],
              ),
            )
          else
            ...availableTeachers.map((t) {
              final isSelected = selectedTeacher?.id == t.id;
              return _TeacherCard(
                teacher: t,
                isSelected: isSelected,
                selectedStartTime: isSelected ? selectedStartTime : null,
                onSelect: () => onSelectTeacher(t),
                onSelectSlot: onSelectSlot,
              );
            }),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Teacher Card (inside step 1)
// ─────────────────────────────────────────────────────────────────────────────
class _TeacherCard extends StatelessWidget {
  final AvailableTeacher teacher;
  final bool isSelected;
  final String? selectedStartTime;
  final VoidCallback onSelect;
  final void Function(String start, String end) onSelectSlot;

  const _TeacherCard({
    required this.teacher,
    required this.isSelected,
    required this.selectedStartTime,
    required this.onSelect,
    required this.onSelectSlot,
  });

  String _displayTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = (parts.length > 1 ? parts[1] : '00').padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final workloadPct =
        (teacher.workloadScore * 100).round();

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary.withValues(alpha: 0.06)
              : context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color:
                isSelected ? context.colors.primary : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Teacher header row
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: context.colors.primaryLight,
                    child: Text(
                      teacher.fullName[0].toUpperCase(),
                      style: context.textStyles.heading3.copyWith(
                          color: context.colors.primary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher.fullName,
                            style: context.textStyles.labelBold),
                        Text(teacher.designation,
                            style: context.textStyles.bodySmall),
                      ],
                    ),
                  ),
                  // Workload indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${teacher.sessionsToday}/${teacher.maxSessionsPerDay}',
                        style: context.textStyles.caption.copyWith(
                            fontWeight: FontWeight.w700),
                      ),
                      Text('sessions',
                          style: context.textStyles.caption
                              .copyWith(color: context.colors.textMuted)),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded,
                        color: context.colors.primary, size: 20),
                ],
              ),
            ),

            // Workload bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: teacher.workloadScore.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: context.colors.bgMuted,
                  color: workloadPct < 50
                      ? context.colors.success
                      : workloadPct < 80
                          ? context.colors.warning
                          : context.colors.danger,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Available time slots (shown when this teacher is selected)
            if (isSelected) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Time Slots',
                        style: context.textStyles.caption.copyWith(
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: teacher.availableSlots.map((slot) {
                        final start = slot.startTime;
                        final end = slot.endTime;
                        final isSlotSelected =
                            selectedStartTime == start;
                        return GestureDetector(
                          onTap: () => onSelectSlot(start, end),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSlotSelected
                                  ? context.colors.primary
                                  : context.colors.primaryLight,
                              borderRadius: BorderRadius.circular(
                                  AppRadius.md),
                            ),
                            child: Text(
                              '${_displayTime(start)} – ${_displayTime(end)}',
                              style: context.textStyles.caption.copyWith(
                                color: isSlotSelected
                                    ? context.colors.white
                                    : context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ] else
              const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Step 2 – Review & Confirm
// ─────────────────────────────────────────────────────────────────────────────
class _StepReview extends StatelessWidget {
  final String childName;
  final AvailableTeacher? teacher;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final TextEditingController notesCtrl;

  const _StepReview({
    required this.childName,
    required this.teacher,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.notesCtrl,
  });

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _displayTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = (parts.length > 1 ? parts[1] : '00').padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review & Confirm', style: context.textStyles.heading3),
        const SizedBox(height: 4),
        Text('Check your booking details before confirming.',
            style: context.textStyles.bodyMuted),
        const SizedBox(height: AppSpacing.xl),

        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: [
              _ReviewRow(
                icon: Icons.face_rounded,
                label: 'Child',
                value: childName,
              ),
              const Divider(),
              _ReviewRow(
                icon: Icons.person_rounded,
                label: 'Teacher',
                value: teacher?.fullName ?? '—',
                subtitle: teacher?.designation,
              ),
              const Divider(),
              _ReviewRow(
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: date != null ? _fmtDate(date!) : '—',
              ),
              const Divider(),
              _ReviewRow(
                icon: Icons.schedule_rounded,
                label: 'Time',
                value: startTime != null && endTime != null
                    ? '${_displayTime(startTime!)} – ${_displayTime(endTime!)}'
                    : '—',
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        TextFormField(
          controller: notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'Any special requirements or notes for the caregiver...',
            filled: true,
            fillColor: context.colors.bgSurface,
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
              borderSide:
                  BorderSide(color: context.colors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_rounded,
                  color: context.colors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Availability has been verified. Your booking will be confirmed once submitted.',
                  style: context.textStyles.caption
                      .copyWith(color: context.colors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: context.colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textStyles.caption),
                Text(value, style: context.textStyles.labelBold),
                if (subtitle != null)
                  Text(subtitle!, style: context.textStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step Indicator
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    const labels = ['Child', 'Date & Teacher', 'Confirm'];
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      color: context.colors.bgLight,
      child: Row(
        children: List.generate(total, (i) {
          final isActive = i == current;
          final isDone = i < current;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        decoration: BoxDecoration(
                          color: isDone || isActive
                              ? context.colors.primary
                              : context.colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: context.textStyles.caption.copyWith(
                          color: isActive
                              ? context.colors.primary
                              : isDone
                                  ? context.colors.success
                                  : context.colors.textMuted,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < total - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int step;
  final bool canNext;
  final bool isSaving;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const _BottomNav({
    required this.step,
    required this.canNext,
    required this.isSaving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.bgLight,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.lg)),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: canNext && !isSaving ? onNext : null,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.lg)),
              ),
              child: isSaving && step == 2
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      step < 2 ? 'Next' : 'Confirm Booking',
                      style: context.textStyles.buttonLabel,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
