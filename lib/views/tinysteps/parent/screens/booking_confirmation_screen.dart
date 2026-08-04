import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/Models/session_booking_model.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Booking Confirmation Screen
// Shown after a successful booking — displays summary and status
// ─────────────────────────────────────────────────────────────────────────────
class BookingConfirmationScreen extends StatelessWidget {
  final SessionBookingModel booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // ── Success animation / icon ──────────────────────────
                    _SuccessBadge(),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Booking Confirmed!',
                      style: context.textStyles.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Your session has been booked.\nYou\'ll be notified once a caregiver is assigned.',
                      style: context.textStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Booking detail card ───────────────────────────────
                    _BookingDetailCard(booking: booking),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Status badge ──────────────────────────────────────
                    _StatusBadge(status: booking.status),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // ── Action buttons ────────────────────────────────────────────
            _ActionButtons(
              onViewBookings: () {
                context.go('/parent/sessions');
              },
              onGoHome: () {
                context.go('/parent');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success Badge
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary,
            context.colors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 52,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Detail Card
// ─────────────────────────────────────────────────────────────────────────────
class _BookingDetailCard extends StatelessWidget {
  final SessionBookingModel booking;

  const _BookingDetailCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.event_available_rounded,
                    color: context.colors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Booking Details',
                  style: context.textStyles.labelBold),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),

          // Detail rows
          _DetailRow(
            icon: Icons.person_rounded,
            label: 'Teacher',
            value: booking.teacherName ?? 'Assigned by admin',
            valueStyle: context.textStyles.labelBold,
          ),
          if (booking.teacherDesignation != null) ...[
            _DetailRow(
              icon: Icons.work_outline_rounded,
              label: 'Role',
              value: booking.teacherDesignation!,
            ),
          ],
          _DetailRow(
            icon: Icons.face_rounded,
            label: 'Child',
            value: booking.childName ?? '—',
          ),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: booking.formattedDate,
          ),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Start Time',
            value: booking.formattedStartTime,
          ),
          _DetailRow(
            icon: Icons.timelapse_rounded,
            label: 'End Time',
            value: booking.formattedEndTime,
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            _DetailRow(
              icon: Icons.notes_rounded,
              label: 'Notes',
              value: booking.notes!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: context.textStyles.caption
                        .copyWith(color: context.colors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ?? context.textStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bgColor, icon) = switch (status) {
      'confirmed' => (
          'Confirmed',
          context.colors.success,
          context.colors.successLight,
          Icons.check_circle_rounded,
        ),
      'cancelled' => (
          'Cancelled',
          context.colors.danger,
          context.colors.dangerLight,
          Icons.cancel_rounded,
        ),
      _ => (
          'Pending',
          context.colors.warning,
          context.colors.warningLight,
          Icons.hourglass_top_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Status: $label',
            style: context.textStyles.labelBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final VoidCallback onViewBookings;
  final VoidCallback onGoHome;

  const _ActionButtons({
    required this.onViewBookings,
    required this.onGoHome,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onViewBookings,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
              ),
              icon: const Icon(Icons.event_note_rounded,
                  color: Colors.white),
              label: Text('View My Bookings',
                  style: context.textStyles.buttonLabel),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onGoHome,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
                side: BorderSide(color: context.colors.border),
              ),
              icon: Icon(Icons.home_rounded,
                  color: context.colors.textMedium),
              label: Text('Go to Home',
                  style: context.textStyles.labelBold
                      .copyWith(color: context.colors.textMedium)),
            ),
          ),
        ],
      ),
    );
  }
}
