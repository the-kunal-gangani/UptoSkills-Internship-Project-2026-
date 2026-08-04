import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/Controllers/teacher_availability_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Teacher Availability Screen
// Staff side: set weekly availability slots, break times, max sessions/day
// ─────────────────────────────────────────────────────────────────────────────
class TeacherAvailabilityScreen extends ConsumerStatefulWidget {
  const TeacherAvailabilityScreen({super.key});

  @override
  ConsumerState<TeacherAvailabilityScreen> createState() =>
      _TeacherAvailabilityScreenState();
}

class _TeacherAvailabilityScreenState
    extends ConsumerState<TeacherAvailabilityScreen> {
  // Local editable schedule: dayOfWeek → list of slot drafts
  final Map<int, List<_SlotDraft>> _schedule = {};
  int _maxSessionsPerDay = 6;
  bool _hasChanges = false;

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    // Init all 7 days with empty lists
    for (int i = 0; i < 7; i++) {
      _schedule[i] = [];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _populateFromState();
  }

  void _populateFromState() {
    final slots = ref.read(teacherAvailabilityProvider).slots;
    if (slots.isEmpty) return;
    _maxSessionsPerDay = slots.first.maxSessionsPerDay;
    for (int i = 0; i < 7; i++) {
      _schedule[i] = slots
          .where((s) => s.dayOfWeek == i)
          .map((s) => _SlotDraft(
                id: s.id,
                startTime: _parseTime(s.startTime),
                endTime: _parseTime(s.endTime),
                status: s.status,
              ))
          .toList();
    }
    if (mounted) setState(() {});
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _displayTime(TimeOfDay t) {
    final hour = t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  void _addSlot(int day) {
    setState(() {
      _schedule[day]!.add(_SlotDraft(
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        status: 'available',
      ));
      _hasChanges = true;
    });
  }

  void _removeSlot(int day, int index) {
    setState(() {
      _schedule[day]!.removeAt(index);
      _hasChanges = true;
    });
  }

  Future<void> _pickTime(
    int day,
    int slotIndex, {
    required bool isStart,
  }) async {
    final draft = _schedule[day]![slotIndex];
    final initial = isStart ? draft.startTime : draft.endTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx)
              .colorScheme
              .copyWith(primary: context.colors.primary),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    setState(() {
      if (isStart) {
        _schedule[day]![slotIndex] = draft.copyWith(startTime: picked);
      } else {
        _schedule[day]![slotIndex] = draft.copyWith(endTime: picked);
      }
      _hasChanges = true;
    });
  }

  void _setStatus(int day, int slotIndex, String status) {
    setState(() {
      _schedule[day]![slotIndex] =
          _schedule[day]![slotIndex].copyWith(status: status);
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    final slots = <Map<String, dynamic>>[];

    for (final entry in _schedule.entries) {
      for (final draft in entry.value) {
        final startMinutes =
            draft.startTime.hour * 60 + draft.startTime.minute;
        final endMinutes = draft.endTime.hour * 60 + draft.endTime.minute;

        if (endMinutes <= startMinutes) {
          _showError('End time must be after start time for ${_dayNames[entry.key]}.');
          return;
        }

        slots.add({
          'dayOfWeek': entry.key,
          'startTime': _fmtTime(draft.startTime),
          'endTime': _fmtTime(draft.endTime),
          'status': draft.status,
          'maxSessionsPerDay': _maxSessionsPerDay,
        });
      }
    }

    final ok = await ref
        .read(teacherAvailabilityProvider.notifier)
        .saveWeeklySchedule(slots);

    if (!mounted) return;
    if (ok) {
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Availability saved successfully!'),
          backgroundColor: context.colors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      );
    } else {
      final error = ref.read(teacherAvailabilityProvider).error;
      _showError(error ?? 'Failed to save. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teacherAvailabilityProvider);

    // Populate on first load
    ref.listen<TeacherAvailabilityState>(teacherAvailabilityProvider,
        (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        _populateFromState();
      }
    });

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('My Availability', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _hasChanges ? _save : null,
              child: Text(
                'Save',
                style: context.textStyles.labelBold.copyWith(
                  color: _hasChanges
                      ? context.colors.primary
                      : context.colors.textMuted,
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header info ──────────────────────────────────────────
                  _InfoBanner(
                    message:
                        'Set your weekly availability. Parents will only see your available slots when booking.',
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Max sessions per day ─────────────────────────────────
                  _MaxSessionsCard(
                    value: _maxSessionsPerDay,
                    onChanged: (v) {
                      setState(() {
                        _maxSessionsPerDay = v;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Day cards ────────────────────────────────────────────
                  ...List.generate(7, (day) {
                    return _DayCard(
                      dayName: _dayNames[day],
                      slots: _schedule[day] ?? [],
                      onAddSlot: () => _addSlot(day),
                      onRemoveSlot: (i) => _removeSlot(day, i),
                      onPickTime: (i, isStart) =>
                          _pickTime(day, i, isStart: isStart),
                      onSetStatus: (i, status) =>
                          _setStatus(day, i, status),
                      displayTime: _displayTime,
                    );
                  }),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Save button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          (_hasChanges && !state.isSaving) ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg)),
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              'Save Availability',
                              style: context.textStyles.buttonLabel,
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Banner
// ─────────────────────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final String message;
  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:
            Border.all(color: context.colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: context.colors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: context.textStyles.caption
                    .copyWith(color: context.colors.primaryDark)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Max Sessions Card
// ─────────────────────────────────────────────────────────────────────────────
class _MaxSessionsCard extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const _MaxSessionsCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.secondaryLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.event_repeat_rounded,
                color: context.colors.secondary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Max Sessions Per Day',
                    style: context.textStyles.labelBold),
                Text('How many sessions can you handle daily?',
                    style: context.textStyles.bodySmall),
              ],
            ),
          ),
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove,
                onTap: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm),
                child: Text(
                  '$value',
                  style: context.textStyles.heading3,
                ),
              ),
              _CounterButton(
                icon: Icons.add,
                onTap: value < 20 ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onTap != null
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.bgMuted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? context.colors.primary
              : context.colors.textMuted,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Card
// ─────────────────────────────────────────────────────────────────────────────
class _DayCard extends StatelessWidget {
  final String dayName;
  final List<_SlotDraft> slots;
  final VoidCallback onAddSlot;
  final void Function(int) onRemoveSlot;
  final void Function(int, bool isStart) onPickTime;
  final void Function(int, String) onSetStatus;
  final String Function(TimeOfDay) displayTime;

  const _DayCard({
    required this.dayName,
    required this.slots,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onPickTime,
    required this.onSetStatus,
    required this.displayTime,
  });

  @override
  Widget build(BuildContext context) {
    final hasSlots = slots.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasSlots
              ? context.colors.primary.withValues(alpha: 0.3)
              : context.colors.border,
        ),
      ),
      child: Column(
        children: [
          // Day header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasSlots
                        ? context.colors.success
                        : context.colors.textMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(dayName,
                      style: context.textStyles.labelBold),
                ),
                Text(
                  hasSlots ? '${slots.length} slot(s)' : 'No slots',
                  style: context.textStyles.caption.copyWith(
                    color: hasSlots
                        ? context.colors.success
                        : context.colors.textMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: onAddSlot,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add,
                            size: 14, color: context.colors.primary),
                        const SizedBox(width: 2),
                        Text('Add',
                            style: context.textStyles.caption.copyWith(
                                color: context.colors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Slots
          if (hasSlots)
            const Divider(height: 1),
          ...List.generate(slots.length, (i) {
            final draft = slots[i];
            return _SlotRow(
              draft: draft,
              index: i,
              isLast: i == slots.length - 1,
              displayTime: displayTime,
              onRemove: () => onRemoveSlot(i),
              onPickStart: () => onPickTime(i, true),
              onPickEnd: () => onPickTime(i, false),
              onSetStatus: (s) => onSetStatus(i, s),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slot Row
// ─────────────────────────────────────────────────────────────────────────────
class _SlotRow extends StatelessWidget {
  final _SlotDraft draft;
  final int index;
  final bool isLast;
  final String Function(TimeOfDay) displayTime;
  final VoidCallback onRemove;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final void Function(String) onSetStatus;

  const _SlotRow({
    required this.draft,
    required this.index,
    required this.isLast,
    required this.displayTime,
    required this.onRemove,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSetStatus,
  });

  Color _statusColor(BuildContext context, String status) {
    return switch (status) {
      'available' => context.colors.success,
      'break' => context.colors.warning,
      _ => context.colors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Slot number badge
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _statusColor(context, draft.status)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: context.textStyles.caption.copyWith(
                      color: _statusColor(context, draft.status),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Time pickers
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TimeChip(
                          label: displayTime(draft.startTime),
                          icon: Icons.schedule_rounded,
                          onTap: onPickStart,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs),
                          child: Text('–',
                              style: context.textStyles.bodyMuted),
                        ),
                        _TimeChip(
                          label: displayTime(draft.endTime),
                          icon: Icons.timelapse_rounded,
                          onTap: onPickEnd,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Status selector
                    Row(
                      children: [
                        _StatusChip(
                          label: 'Available',
                          value: 'available',
                          selected: draft.status,
                          color: context.colors.success,
                          onTap: () => onSetStatus('available'),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _StatusChip(
                          label: 'Break',
                          value: 'break',
                          selected: draft.status,
                          color: context.colors.warning,
                          onTap: () => onSetStatus('break'),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _StatusChip(
                          label: 'Busy',
                          value: 'busy',
                          selected: draft.status,
                          color: context.colors.danger,
                          onTap: () => onSetStatus('busy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: context.colors.danger, size: 20),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: context.colors.border),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TimeChip(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.bgMuted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: context.colors.textMuted),
            const SizedBox(width: 4),
            Text(label,
                style: context.textStyles.caption
                    .copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
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
            horizontal: AppSpacing.sm, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? color : context.colors.border,
          ),
        ),
        child: Text(
          label,
          style: context.textStyles.caption.copyWith(
            color: isSelected ? color : context.colors.textMuted,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slot Draft Model (local state only)
// ─────────────────────────────────────────────────────────────────────────────
class _SlotDraft {
  final String? id; // null = new slot not yet saved
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String status; // 'available' | 'break' | 'busy'

  const _SlotDraft({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  _SlotDraft copyWith({
    String? id,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? status,
  }) =>
      _SlotDraft(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
      );
}
