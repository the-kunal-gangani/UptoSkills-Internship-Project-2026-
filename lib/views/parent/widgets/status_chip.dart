import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

/// A small UI badge for displaying status
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;

    // "Checked In" -> Green, "At Home" -> Red/Grey, "Checked Out" -> Blue
    switch (status) {
      case 'Checked In':
      case 'In Class':
        color = context.colors.success;
        bgColor = context.colors.successLight;
        break;
      case 'At Home':
        color = context.colors.danger;
        bgColor = context.colors.dangerLight;
        break;
      case 'Checked Out':
        color = context.colors.danger;
        bgColor = context.colors.dangerLight;
        break;
      default:
        color = context.colors.textMuted;
        bgColor = context.colors.divider;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status.toUpperCase(),
        style: context.textStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
