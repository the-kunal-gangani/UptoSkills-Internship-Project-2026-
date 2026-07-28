import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tinysteps/controllers/staff_schedule_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/views/staff/widgets/emergency_dialer_overlay.dart';

class MyScheduleScreen extends ConsumerStatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  ConsumerState<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends ConsumerState<MyScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staffScheduleProvider);
    final daysSessions = state.sessionsForDate(_selectedDay);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('My Schedule', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(staffScheduleProvider.notifier).loadSchedule(),
          ),
        ],
      ),
      body: state.isLoading
          ? Center(
              child:
                  CircularProgressIndicator(color: context.colors.primary))
          : Column(
              children: [
                // ── Calendar ────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.now()
                        .subtract(const Duration(days: 60)),
                    lastDay: DateTime.now()
                        .add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(day, _selectedDay),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    eventLoader: (day) =>
                        state.sessionsForDate(day),
                    calendarFormat: CalendarFormat.week,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: context.textStyles.labelBold,
                      leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: context.colors.primary),
                      rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: context.colors.primary),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: context.colors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle:
                          TextStyle(color: context.colors.primary),
                      selectedDecoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: context.colors.accent,
                        shape: BoxShape.circle,
                      ),
                      markerSize: 5,
                      markersMaxCount: 3,
                      weekendTextStyle:
                          TextStyle(color: context.colors.textMedium),
                    ),
                  ),
                ),
                // ── Session list for selected day ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Text(
                        _formatDay(_selectedDay),
                        style: context.textStyles.heading3,
                      ),
                      const Spacer(),
                      Text(
                        '${daysSessions.length} session${daysSessions.length == 1 ? '' : 's'}',
                        style: context.textStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: daysSessions.isEmpty
                      ? _EmptyDay()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg),
                          itemCount: daysSessions.length,
                          itemBuilder: (context, i) => _SessionTile(
                            session: daysSessions[i],
                            onStart: () async {
                              final ok = await ref
                                  .read(staffScheduleProvider.notifier)
                                  .startSession(
                                      daysSessions[i]['id'] as String);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      ok ? 'Session started!' : 'Failed'),
                                  backgroundColor: ok
                                      ? context.colors.success
                                      : context.colors.danger,
                                ));
                              }
                            },
                            onEnd: () async {
                              final ok = await ref
                                  .read(staffScheduleProvider.notifier)
                                  .endSession(
                                      daysSessions[i]['id'] as String);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      ok ? 'Session completed!' : 'Failed'),
                                  backgroundColor: ok
                                      ? context.colors.success
                                      : context.colors.danger,
                                ));
                              }
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDay(DateTime d) {
    final today = DateTime.now();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (isSameDay(d, today)) return 'Today';
    if (isSameDay(d, tomorrow)) return 'Tomorrow';
    const days = [
      '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]}';
  }
}

class _EmptyDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_rounded,
              size: 52, color: context.colors.border),
          const SizedBox(height: AppSpacing.md),
          Text('No sessions this day',
              style: context.textStyles.bodyMuted),
        ],
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  final Map<String, dynamic> session;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  const _SessionTile({
    required this.session,
    required this.onStart,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = session['status'] as String? ?? 'confirmed';
    final start = session['scheduled_start'] as String? ?? '';
    final end = session['scheduled_end'] as String? ?? '';
    final locationType =
        session['location_type'] as String? ?? 'home';
    final parent = session['parents'] as Map<String, dynamic>?;
    final parentName =
        parent?['full_name'] as String? ?? 'Parent';
    final parentPhone = parent?['phone'] as String? ?? '';
    final parentAddress = parent?['address'] as String? ?? '';
    final childLinks =
        (session['session_children'] as List<dynamic>?) ?? [];
    final children = childLinks
        .map((sc) => sc['children'] as Map<String, dynamic>?)
        .where((c) => c != null)
        .toList();

    final isInProgress = status == 'in_progress';
    final isConfirmed = status == 'confirmed';

    Color accentColor = isInProgress
        ? context.colors.success
        : isConfirmed
            ? context.colors.primary
            : context.colors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isInProgress
              ? context.colors.success.withValues(alpha: 0.5)
              : context.colors.border,
          width: isInProgress ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '$start – $end',
                    style: context.textStyles.labelBold.copyWith(
                        color: accentColor, fontSize: 12),
                  ),
                ),
                const Spacer(),
                if (isInProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          context.colors.success.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle,
                            size: 8, color: context.colors.success),
                        const SizedBox(width: 4),
                        Text('In Progress',
                            style: context.textStyles.caption.copyWith(
                              color: context.colors.success,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Parent info
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.primaryLight,
                  child: Text(
                    parentName.isNotEmpty
                        ? parentName[0].toUpperCase()
                        : 'P',
                    style: context.textStyles.labelBold
                        .copyWith(color: context.colors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(parentName,
                          style: context.textStyles.labelBold),
                      if (parentPhone.isNotEmpty)
                        Text(parentPhone,
                            style: context.textStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            if (locationType == 'home' && parentAddress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 14, color: context.colors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(parentAddress,
                          style: context.textStyles.bodySmall),
                    ),
                  ],
                ),
              )
            else if (locationType == 'staff_home')
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.cottage_rounded,
                        size: 14, color: context.colors.textMuted),
                    const SizedBox(width: 4),
                    Text('Child coming to your home',
                        style: context.textStyles.bodySmall),
                  ],
                ),
              ),
            // Children
            if (children.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                children: children.map((c) {
                  final name =
                      c?['full_name'] as String? ?? 'Child';
                  final allergy =
                      c?['allergies'] as String?;
                  return Tooltip(
                    message:
                        allergy != null && allergy.isNotEmpty
                            ? 'Allergies: $allergy'
                            : 'No known allergies',
                    child: Chip(
                      label: Text(name,
                          style: context.textStyles.caption),
                      avatar: CircleAvatar(
                        backgroundColor:
                            context.colors.accent.withValues(alpha: 0.2),
                        child: Text(name[0].toUpperCase(),
                            style:
                                const TextStyle(fontSize: 10)),
                      ),
                      backgroundColor:
                          context.colors.accentLight.withValues(alpha: 0.3),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
            ],
            // Action buttons
            if (isConfirmed || isInProgress) ...[
              const SizedBox(height: AppSpacing.md),
              if (isInProgress) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/chat/${session['id']}'),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text('Chat'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          // Trigger database alert record
                          await ref.read(staffScheduleProvider.notifier).triggerSosAlert(session['id'] as String);
                          if (context.mounted) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => EmergencyDialerOverlay(
                                parentName: parentName,
                                parentPhone: parentPhone,
                                adminName: 'TinySteps Support',
                                adminPhone: '1800123456',
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colors.danger,
                        ),
                        icon: const Icon(Icons.emergency_rounded, size: 18),
                        label: const Text('SOS Alert'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              SizedBox(
                width: double.infinity,
                child: isConfirmed
                    ? FilledButton.icon(
                        onPressed: onStart,
                        style: FilledButton.styleFrom(
                            backgroundColor: context.colors.success),
                        icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 18),
                        label: const Text('Start Session'),
                      )
                    : FilledButton.icon(
                        onPressed: onEnd,
                        style: FilledButton.styleFrom(
                            backgroundColor: context.colors.danger.withValues(alpha: 0.8)),
                        icon: const Icon(Icons.stop_rounded, size: 18),
                        label: const Text('End Session'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
