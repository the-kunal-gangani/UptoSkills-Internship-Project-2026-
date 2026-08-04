import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/Controllers/admin_sessions_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminSessionsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: context.colors.bgLight,
        appBar: AppBar(
          title: Text('Sessions', style: context.textStyles.heading2),
          backgroundColor: context.colors.bgLight,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () =>
                  ref.read(adminSessionsProvider.notifier).loadAll(),
            ),
          ],
          bottom: TabBar(
            labelColor: context.colors.primary,
            unselectedLabelColor: context.colors.textMuted,
            indicatorColor: context.colors.primary,
            labelStyle: context.textStyles.labelBold,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              // ── New Bookings tab (session_bookings table) ────────────────
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('New Bookings'),
                    if (state.newBookingsPendingCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.secondary,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${state.newBookingsPendingCount}',
                          style: context.textStyles.caption.copyWith(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // ── Old sessions tabs ────────────────────────────────────────
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pending'),
                    if (state.pendingCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.danger,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${state.pendingCount}',
                          style: context.textStyles.caption.copyWith(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Upcoming'),
              const Tab(text: 'All'),
            ],
          ),
        ),
        body: state.isLoading
            ? Center(
                child:
                    CircularProgressIndicator(color: context.colors.primary))
            : TabBarView(
                children: [
                  // ── Tab 0: New Bookings (session_bookings table) ─────────
                  _NewBookingsList(
                    bookings: state.pendingBookings,
                    onRefresh: () =>
                        ref.read(adminSessionsProvider.notifier).loadAll(),
                    onConfirm: (id) async {
                      final ok = await ref
                          .read(adminSessionsProvider.notifier)
                          .confirmBooking(id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Booking confirmed!'
                              : 'Failed to confirm booking'),
                          backgroundColor: ok
                              ? context.colors.success
                              : context.colors.danger,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md)),
                        ));
                      }
                    },
                    onReject: (id) async {
                      final ok = await ref
                          .read(adminSessionsProvider.notifier)
                          .rejectBooking(id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Booking rejected.'
                              : 'Failed to reject booking'),
                          backgroundColor: ok
                              ? context.colors.warning
                              : context.colors.danger,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md)),
                        ));
                      }
                    },
                  ),

                  // ── Tab 1: Pending (old sessions table) ──────────────────
                  _AdminSessionList(
                    sessions: state.pending,
                    availableStaff: state.availableStaff,
                    emptyMsg: 'No pending bookings',
                    emptyIcon: Icons.inbox_rounded,
                    showAssignAction: true,
                    onRefresh: () =>
                        ref.read(adminSessionsProvider.notifier).loadAll(),
                    onAssign: (sessionId, staffId) async {
                      final ok = await ref
                          .read(adminSessionsProvider.notifier)
                          .assignStaff(sessionId, staffId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Caregiver assigned & session confirmed'
                              : 'Assignment failed'),
                          backgroundColor: ok
                              ? context.colors.success
                              : context.colors.danger,
                        ));
                      }
                    },
                    onCancel: (id) async {
                      await ref
                          .read(adminSessionsProvider.notifier)
                          .cancelSession(id);
                    },
                  ),

                  // ── Tab 2: Upcoming (old sessions table) ─────────────────
                  _AdminSessionList(
                    sessions: state.upcoming,
                    availableStaff: state.availableStaff,
                    emptyMsg: 'No upcoming sessions this week',
                    emptyIcon: Icons.event_available_rounded,
                    showAssignAction: false,
                    onRefresh: () =>
                        ref.read(adminSessionsProvider.notifier).loadAll(),
                    onAssign: null,
                    onCancel: null,
                  ),

                  // ── Tab 3: All (old sessions table) ──────────────────────
                  _AdminSessionList(
                    sessions: state.all,
                    availableStaff: state.availableStaff,
                    emptyMsg: 'No sessions yet',
                    emptyIcon: Icons.list_alt_rounded,
                    showAssignAction: false,
                    onRefresh: () =>
                        ref.read(adminSessionsProvider.notifier).loadAll(),
                    onAssign: null,
                    onCancel: null,
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Bookings List (session_bookings table)
// ─────────────────────────────────────────────────────────────────────────────
class _NewBookingsList extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String id) onConfirm;
  final Future<void> Function(String id) onReject;

  const _NewBookingsList({
    required this.bookings,
    required this.onRefresh,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return RefreshIndicator(
        color: context.colors.primary,
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 64, color: context.colors.border),
                  const SizedBox(height: AppSpacing.md),
                  Text('No pending bookings',
                      style: context.textStyles.bodyMuted),
                  const SizedBox(height: AppSpacing.sm),
                  Text('New parent bookings will appear here.',
                      style: context.textStyles.caption),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: context.colors.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: bookings.length,
        itemBuilder: (context, i) => _NewBookingCard(
          booking: bookings[i],
          onConfirm: () => onConfirm(bookings[i]['id'] as String),
          onReject: () => onReject(bookings[i]['id'] as String),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Booking Card (session_bookings table)
// ─────────────────────────────────────────────────────────────────────────────
class _NewBookingCard extends StatefulWidget {
  final Map<String, dynamic> booking;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onReject;

  const _NewBookingCard({
    required this.booking,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  State<_NewBookingCard> createState() => _NewBookingCardState();
}

class _NewBookingCardState extends State<_NewBookingCard> {
  bool _isActing = false;

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
    final b = widget.booking;
    final parent = b['parents'] as Map<String, dynamic>?;
    final teacher = b['teachers'] as Map<String, dynamic>?;
    final child = b['children'] as Map<String, dynamic>?;

    final parentName = parent?['full_name'] as String? ?? 'Unknown Parent';
    final parentPhone = parent?['phone'] as String? ?? '';
    final teacherName = teacher?['full_name'] as String? ?? 'Unknown Teacher';
    final teacherRole = teacher?['designation'] as String? ?? 'Caregiver';
    final childName = child?['full_name'] as String? ?? 'Unknown Child';
    final sessionDate = b['session_date'] as String? ?? '';
    final startTime = b['start_time'] as String? ?? '';
    final endTime = b['end_time'] as String? ?? '';
    final notes = b['notes'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: context.colors.secondary.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.secondary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: date + NEW badge
            Row(
              children: [
                Expanded(
                  child: Text(sessionDate,
                      style: context.textStyles.heading3),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.secondary
                        .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_new_rounded,
                          size: 14, color: context.colors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'PENDING',
                        style: context.textStyles.caption.copyWith(
                          color: context.colors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Details
            _Row(Icons.schedule_rounded,
                '${_displayTime(startTime)} – ${_displayTime(endTime)}'),
            _Row(Icons.person_rounded, 'Parent: $parentName'),
            if (parentPhone.isNotEmpty)
              _Row(Icons.phone_rounded, parentPhone),
            _Row(Icons.face_rounded, 'Child: $childName'),
            _Row(Icons.badge_rounded,
                'Teacher: $teacherName ($teacherRole)'),
            if (notes != null && notes.isNotEmpty)
              _Row(Icons.notes_rounded, 'Notes: $notes'),

            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),

            // Confirm / Reject actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isActing
                        ? null
                        : () async {
                            setState(() => _isActing = true);
                            await widget.onReject();
                            if (mounted) setState(() => _isActing = false);
                          },
                    icon: Icon(Icons.close_rounded,
                        size: 16, color: context.colors.danger),
                    label: Text('Reject',
                        style: context.textStyles.labelBold
                            .copyWith(color: context.colors.danger)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: context.colors.danger
                              .withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _isActing
                        ? null
                        : () async {
                            setState(() => _isActing = true);
                            await widget.onConfirm();
                            if (mounted) setState(() => _isActing = false);
                          },
                    icon: _isActing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_rounded, size: 16),
                    label: Text(_isActing ? 'Confirming…' : 'Confirm',
                        style: context.textStyles.buttonLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.success,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Old Sessions List (unchanged from before)
// ─────────────────────────────────────────────────────────────────────────────
class _AdminSessionList extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final List<Map<String, dynamic>> availableStaff;
  final String emptyMsg;
  final IconData emptyIcon;
  final bool showAssignAction;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String sessionId, String staffId)? onAssign;
  final Future<void> Function(String)? onCancel;

  const _AdminSessionList({
    required this.sessions,
    required this.availableStaff,
    required this.emptyMsg,
    required this.emptyIcon,
    required this.showAssignAction,
    required this.onRefresh,
    required this.onAssign,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 64, color: context.colors.border),
            const SizedBox(height: AppSpacing.md),
            Text(emptyMsg, style: context.textStyles.bodyMuted),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: context.colors.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: sessions.length,
        itemBuilder: (context, i) => _AdminSessionCard(
          session: sessions[i],
          availableStaff: availableStaff,
          showAssignAction: showAssignAction,
          onAssign: onAssign,
          onCancel: onCancel,
        ),
      ),
    );
  }
}

class _AdminSessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final List<Map<String, dynamic>> availableStaff;
  final bool showAssignAction;
  final Future<void> Function(String, String)? onAssign;
  final Future<void> Function(String)? onCancel;

  const _AdminSessionCard({
    required this.session,
    required this.availableStaff,
    required this.showAssignAction,
    required this.onAssign,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final sessionId = session['id'] as String;
    final status = session['status'] as String? ?? 'pending';
    final dateStr = session['scheduled_date'] as String? ?? '';
    final start = session['scheduled_start'] as String? ?? '';
    final end = session['scheduled_end'] as String? ?? '';
    final locationType = session['location_type'] as String? ?? 'home';
    final parent = session['parents'] as Map<String, dynamic>?;
    final parentName = parent?['full_name'] as String? ?? 'Unknown Parent';
    final parentPhone = parent?['phone'] as String? ?? '';
    final staff = session['teachers'] as Map<String, dynamic>?;
    final staffName = staff?['full_name'] as String?;
    final childLinks = (session['session_children'] as List<dynamic>?) ?? [];
    final childNames = childLinks
        .map((sc) =>
            (sc['children'] as Map?)?['full_name'] as String? ?? 'Child')
        .join(', ');
    final notes = session['notes'] as String?;

    final Color statusColor = switch (status) {
      'pending' => context.colors.warning,
      'confirmed' => context.colors.primary,
      'in_progress' => context.colors.success,
      'completed' => context.colors.textMuted,
      _ => context.colors.danger,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(dateStr,
                        style: context.textStyles.heading3)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: context.textStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _Row(Icons.schedule_rounded, '$start – $end'),
            _Row(
              locationType == 'home'
                  ? Icons.home_rounded
                  : Icons.cottage_rounded,
              locationType == 'home'
                  ? 'Parent\'s Home'
                  : 'Caregiver\'s Home',
            ),
            _Row(Icons.person_rounded, 'Parent: $parentName'),
            if (parentPhone.isNotEmpty)
              _Row(Icons.phone_rounded, parentPhone),
            _Row(Icons.face_rounded,
                'Children: ${childNames.isEmpty ? '—' : childNames}'),
            _Row(
              Icons.badge_rounded,
              staffName != null
                  ? 'Caregiver: $staffName'
                  : 'Caregiver: Not yet assigned',
            ),
            if (notes != null && notes.isNotEmpty)
              _Row(Icons.notes_rounded, 'Notes: $notes'),
            if (showAssignAction &&
                onAssign != null &&
                availableStaff.isNotEmpty)
              _AssignStaffButton(
                sessionId: sessionId,
                availableStaff: availableStaff,
                onAssign: onAssign!,
              ),
            if (onCancel != null && status == 'pending') ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onCancel!(sessionId),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel Booking'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.danger,
                    side: BorderSide(
                        color: context.colors.danger
                            .withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssignStaffButton extends StatefulWidget {
  final String sessionId;
  final List<Map<String, dynamic>> availableStaff;
  final Future<void> Function(String sessionId, String staffId) onAssign;

  const _AssignStaffButton({
    required this.sessionId,
    required this.availableStaff,
    required this.onAssign,
  });

  @override
  State<_AssignStaffButton> createState() => _AssignStaffButtonState();
}

class _AssignStaffButtonState extends State<_AssignStaffButton> {
  String? _selectedStaffId;
  bool _isAssigning = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        Text('Assign Caregiver', style: context.textStyles.labelBold),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: _selectedStaffId,
          hint: Text('Select caregiver',
              style: context.textStyles.bodyMuted),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.colors.bgLight,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: context.colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: context.colors.border),
            ),
          ),
          dropdownColor: context.colors.bgSurface,
          items: widget.availableStaff
              .map((s) => DropdownMenuItem<String>(
                    value: s['id'] as String,
                    child: Text(s['full_name'] as String? ?? 'Staff'),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedStaffId = v),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: _selectedStaffId == null || _isAssigning
              ? null
              : () async {
                  setState(() => _isAssigning = true);
                  await widget.onAssign(
                      widget.sessionId, _selectedStaffId!);
                  if (mounted) setState(() => _isAssigning = false);
                },
          icon: _isAssigning
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(_isAssigning ? 'Assigning…' : 'Confirm Assignment'),
          style: FilledButton.styleFrom(
              backgroundColor: context.colors.success),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.colors.textMuted),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text, style: context.textStyles.bodySmall)),
        ],
      ),
    );
  }
}
