import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/Controllers/booking_session_controller.dart';
import 'package:tinysteps/Controllers/booking_controller.dart';
import 'package:tinysteps/Models/session_booking_model.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

// ─────────────────────────────────────────────────────────────────────────────
// My Sessions Screen
// Shows both old (sessions table) and new (session_bookings table) bookings.
// Tabs: My Bookings (new) | Upcoming | Pending | Past
// ─────────────────────────────────────────────────────────────────────────────
class MySessionsScreen extends ConsumerWidget {
  const MySessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oldState = ref.watch(bookingProvider);
    final newState = ref.watch(bookingSessionProvider);

    final isLoading = oldState.isLoading || newState.isLoading;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: context.colors.bgLight,
        appBar: AppBar(
          title: Text('My Sessions', style: context.textStyles.heading2),
          backgroundColor: context.colors.bgLight,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () {
                ref.read(bookingProvider.notifier).loadSessions();
                ref.read(bookingSessionProvider.notifier).loadMyBookings();
              },
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
              // New bookings tab with badge
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('My Bookings'),
                    if (newState.myBookings
                        .where((b) => b.isPending)
                        .isNotEmpty) ...[
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
                          '${newState.myBookings.where((b) => b.isPending).length}',
                          style: context.textStyles.caption
                              .copyWith(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Upcoming'),
              const Tab(text: 'Pending'),
              const Tab(text: 'Past'),
            ],
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: context.colors.primary))
            : TabBarView(
                children: [
                  // ── Tab 0: New bookings (session_bookings table) ─────────
                  _NewBookingsList(
                    bookings: newState.myBookings,
                    onRefresh: () => ref
                        .read(bookingSessionProvider.notifier)
                        .loadMyBookings(),
                    onCancel: (id) async {
                      final ok = await ref
                          .read(bookingSessionProvider.notifier)
                          .cancelBooking(id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              ok ? 'Booking cancelled' : 'Could not cancel'),
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

                  // ── Tab 1: Upcoming (old sessions table) ─────────────────
                  _OldSessionList(
                    sessions: oldState.sessions
                        .where((s) =>
                            s['status'] == 'confirmed' ||
                            s['status'] == 'in_progress')
                        .toList(),
                    emptyMsg: 'No upcoming sessions',
                    emptyIcon: Icons.event_available_rounded,
                    onRefresh: () =>
                        ref.read(bookingProvider.notifier).loadSessions(),
                    onCancel: null,
                  ),

                  // ── Tab 2: Pending (old sessions table) ──────────────────
                  _OldSessionList(
                    sessions: oldState.sessions
                        .where((s) => s['status'] == 'pending')
                        .toList(),
                    emptyMsg: 'No pending bookings',
                    emptyIcon: Icons.hourglass_empty_rounded,
                    onRefresh: () =>
                        ref.read(bookingProvider.notifier).loadSessions(),
                    onCancel: (id) async {
                      final ok = await ref
                          .read(bookingProvider.notifier)
                          .cancelSession(id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Session cancelled'
                              : 'Could not cancel'),
                        ));
                      }
                    },
                  ),

                  // ── Tab 3: Past (old sessions table) ─────────────────────
                  _OldSessionList(
                    sessions: oldState.sessions
                        .where((s) =>
                            s['status'] == 'completed' ||
                            s['status'] == 'cancelled')
                        .toList(),
                    emptyMsg: 'No past sessions yet',
                    emptyIcon: Icons.history_rounded,
                    onRefresh: () =>
                        ref.read(bookingProvider.notifier).loadSessions(),
                    onCancel: null,
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: context.colors.primary,
          onPressed: () => context.push('/parent/book-session'),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('New Booking',
              style: context.textStyles.buttonLabel
                  .copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Bookings List (session_bookings table)
// ─────────────────────────────────────────────────────────────────────────────
class _NewBookingsList extends StatelessWidget {
  final List<SessionBookingModel> bookings;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String id) onCancel;

  const _NewBookingsList({
    required this.bookings,
    required this.onRefresh,
    required this.onCancel,
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
                  Icon(Icons.event_note_rounded,
                      size: 64, color: context.colors.border),
                  const SizedBox(height: AppSpacing.md),
                  Text('No bookings yet',
                      style: context.textStyles.bodyMuted),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Tap + New Booking to get started.',
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
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
        itemCount: bookings.length,
        itemBuilder: (context, i) => _NewBookingCard(
          booking: bookings[i],
          onCancel: bookings[i].isPending
              ? () => onCancel(bookings[i].id)
              : null,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New Booking Card (session_bookings table)
// ─────────────────────────────────────────────────────────────────────────────
class _NewBookingCard extends StatelessWidget {
  final SessionBookingModel booking;
  final VoidCallback? onCancel;

  const _NewBookingCard({required this.booking, this.onCancel});

  Color _statusColor(BuildContext context) => switch (booking.status) {
        'confirmed' => context.colors.success,
        'cancelled' => context.colors.danger,
        _ => context.colors.warning,
      };

  IconData _statusIcon() => switch (booking.status) {
        'confirmed' => Icons.check_circle_rounded,
        'cancelled' => Icons.cancel_rounded,
        _ => Icons.hourglass_top_rounded,
      };

  String _statusLabel() => switch (booking.status) {
        'confirmed' => 'Confirmed',
        'cancelled' => 'Cancelled',
        _ => 'Pending',
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: booking.isPending
              ? context.colors.secondary.withValues(alpha: 0.4)
              : context.colors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: date + status chip
            Row(
              children: [
                Expanded(
                  child: Text(booking.formattedDate,
                      style: context.textStyles.heading3),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(), size: 12, color: color),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(),
                        style: context.textStyles.caption.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Details
            _InfoLine(
              icon: Icons.schedule_rounded,
              text:
                  '${booking.formattedStartTime} – ${booking.formattedEndTime}',
            ),
            if (booking.teacherName != null)
              _InfoLine(
                icon: Icons.person_rounded,
                text: booking.teacherName!,
              ),
            if (booking.childName != null)
              _InfoLine(
                icon: Icons.face_rounded,
                text: booking.childName!,
              ),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              _InfoLine(
                icon: Icons.notes_rounded,
                text: booking.notes!,
              ),

            // Cancel button for pending bookings
            if (onCancel != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel Booking'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.danger,
                    side: BorderSide(
                        color: context.colors.danger
                            .withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md)),
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

// ─────────────────────────────────────────────────────────────────────────────
// Old Session List (sessions table — unchanged from before)
// ─────────────────────────────────────────────────────────────────────────────
class _OldSessionList extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final String emptyMsg;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String)? onCancel;

  const _OldSessionList({
    required this.sessions,
    required this.emptyMsg,
    required this.emptyIcon,
    required this.onRefresh,
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
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
        itemCount: sessions.length,
        itemBuilder: (context, i) =>
            _OldSessionCard(session: sessions[i], onCancel: onCancel),
      ),
    );
  }
}

class _OldSessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final Future<void> Function(String)? onCancel;

  const _OldSessionCard({required this.session, required this.onCancel});

  Color _statusColor(BuildContext context, String status) =>
      switch (status) {
        'pending' => context.colors.warning,
        'confirmed' => context.colors.primary,
        'in_progress' => context.colors.success,
        'completed' => context.colors.textMuted,
        _ => context.colors.danger,
      };

  IconData _statusIcon(String status) => switch (status) {
        'pending' => Icons.hourglass_top_rounded,
        'confirmed' => Icons.event_available_rounded,
        'in_progress' => Icons.play_circle_filled_rounded,
        'completed' => Icons.check_circle_rounded,
        _ => Icons.cancel_rounded,
      };

  String _statusLabel(String status) => switch (status) {
        'pending' => 'Pending',
        'confirmed' => 'Confirmed',
        'in_progress' => 'In Progress',
        'completed' => 'Completed',
        _ => 'Cancelled',
      };

  @override
  Widget build(BuildContext context) {
    final status = session['status'] as String? ?? 'pending';
    final dateStr = session['scheduled_date'] as String? ?? '';
    final start = session['scheduled_start'] as String? ?? '';
    final end = session['scheduled_end'] as String? ?? '';
    final locationType = session['location_type'] as String? ?? 'home';
    final staff = session['teachers'] as Map<String, dynamic>?;
    final staffName =
        staff?['full_name'] as String? ?? 'Pending assignment';
    final childLinks =
        (session['session_children'] as List<dynamic>?) ?? [];
    final childNames = childLinks
        .map((sc) =>
            (sc['children'] as Map?)?['full_name'] ?? 'Child')
        .join(', ');

    final color = _statusColor(context, status);

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
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status), size: 12, color: color),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(status),
                        style: context.textStyles.caption.copyWith(
                            color: color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoLine(
                icon: Icons.schedule_rounded, text: '$start – $end'),
            _InfoLine(
              icon: locationType == 'home'
                  ? Icons.home_rounded
                  : Icons.cottage_rounded,
              text: locationType == 'home'
                  ? 'Our Home'
                  : 'Caregiver\'s Home',
            ),
            _InfoLine(
                icon: Icons.face_rounded,
                text: childNames.isEmpty ? '—' : childNames),
            _InfoLine(icon: Icons.person_rounded, text: staffName),
            if (onCancel != null && status == 'pending') ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      onCancel!(session['id'] as String),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
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
            if (status == 'in_progress') ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.push('/chat/${session['id']}'),
                  icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18),
                  label: const Text('Chat with Caregiver'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared InfoLine widget
// ─────────────────────────────────────────────────────────────────────────────
class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});

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
