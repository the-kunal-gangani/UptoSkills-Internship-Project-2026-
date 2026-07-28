import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tinysteps/controllers/alert_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ActiveAlertDialog extends ConsumerStatefulWidget {
  final EmergencyAlert alert;

  const ActiveAlertDialog({super.key, required this.alert});

  @override
  ConsumerState<ActiveAlertDialog> createState() => _ActiveAlertDialogState();
}

class _ChatBubbleFlashingPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _ChatBubbleFlashingPainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15 * (1.0 - animationValue))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width / 2) * (1.0 + animationValue * 1.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChatBubbleFlashingPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _ActiveAlertDialogState extends ConsumerState<ActiveAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  Timer? _vibrationTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Start repeating vibration haptics every 1.5 seconds
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      HapticFeedback.vibrate();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _vibrationTimer?.cancel();
    super.dispose();
  }

  Future<void> _callPhone(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.alert;
    final role = Supabase.instance.client.auth.currentUser?.userMetadata?['role'] as String? ?? 'parent';
    final isAdmin = role == 'admin';

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: context.colors.danger, width: 3),
            boxShadow: [
              BoxShadow(
                color: context.colors.danger.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flashing SOS Pulse
                AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ChatBubbleFlashingPainter(_animCtrl.value, context.colors.danger),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.colors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'CRITICAL EMERGENCY ALERT',
                  style: context.textStyles.heading2.copyWith(
                    color: context.colors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'An SOS distress signal has been triggered by the Caregiver.',
                  style: context.textStyles.labelBold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.bgLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alert Type: ${user.type.toUpperCase()}',
                          style: context.textStyles.labelBold.copyWith(color: context.colors.danger)),
                      const SizedBox(height: 4),
                      Text('Caregiver Notes:', style: context.textStyles.caption),
                      Text(user.notes.isNotEmpty ? user.notes : 'No extra details provided.',
                          style: context.textStyles.bodySmall),
                      const SizedBox(height: 4),
                      Text('Triggered At: ${_formatDateTime(user.createdAt)}',
                          style: context.textStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callPhone('100'), // Quick local emergency
                        icon: const Icon(Icons.local_police_rounded),
                        label: const Text('Call Police'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callPhone('108'), // Quick local ambulance
                        icon: const Icon(Icons.local_hospital_rounded),
                        label: const Text('Ambulance'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade700),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: isAdmin
                      ? FilledButton.icon(
                          onPressed: () async {
                            await ref.read(alertMonitorProvider.notifier).acknowledgeAlert(user.id);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('Acknowledge & Resolve Alert'),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.success,
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: () {
                            ref.read(alertMonitorProvider.notifier).dismissLocalAlert();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Dismiss Notification'),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.textMuted,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
