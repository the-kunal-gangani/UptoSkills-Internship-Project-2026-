import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'child_avatar.dart';
import 'status_chip.dart';

class AttendanceCard extends StatelessWidget {
  final String childName;
  final String time;
  final AttendanceStatus status;

  const AttendanceCard({
    super.key,
    required this.childName,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          ChildAvatar(name: childName),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(childName, style: context.textStyles.bodyLarge),

                const SizedBox(height: 2),

                Text(time, style: context.textStyles.bodySmall),
              ],
            ),
          ),

          StatusChip(status: status),
        ],
      ),
    );
  }
}
