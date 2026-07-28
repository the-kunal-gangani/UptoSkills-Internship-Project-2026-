import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

/// A circular avatar for displaying a child's initials and status
class ChildAvatar extends StatelessWidget {
  final String name;
  final String status;
  final Color color;
  final double size;

  const ChildAvatar({
    super.key,
    required this.name,
    required this.status,
    required this.color,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name, 
          style: context.textStyles.labelBold,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          status,
          textAlign: TextAlign.center,
          style: context.textStyles.bodySmall.copyWith(
            fontSize: 10,
            color: (status == 'Checked In' || status == 'In Class')
                ? context.colors.success
                : status == 'Checked Out'
                    ? context.colors.danger
                    : context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}
