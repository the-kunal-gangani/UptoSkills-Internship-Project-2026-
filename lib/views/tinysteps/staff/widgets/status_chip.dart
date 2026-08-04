import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

enum AttendanceStatus {
  checkedIn,
  checkedOut,
  absent,
}

class StatusChip extends StatelessWidget {
  final AttendanceStatus status;

  const StatusChip({super.key, required this.status});

  Color bgColor(BuildContext context) {
    switch (status) {
      case AttendanceStatus.checkedIn:
        return context.colors.successLight;
      case AttendanceStatus.checkedOut:
        return context.colors.accentLight;
      case AttendanceStatus.absent:
        return context.colors.dangerLight;
    }
  }

  Color textColor(BuildContext context) {
    switch (status) {
      case AttendanceStatus.checkedIn:
        return context.colors.success;
      case AttendanceStatus.checkedOut:
        return context.colors.accent;
      case AttendanceStatus.absent:
        return context.colors.danger;
    }
  }

  String get label {
    switch (status) {
      case AttendanceStatus.checkedIn:
        return "Checked In";
      case AttendanceStatus.checkedOut:
        return "Checked Out";
      case AttendanceStatus.absent:
        return "Absent";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor(context),
        borderRadius: AppRadius.chipRadius,
      ),
      child: Text(
        label,
        style: context.textStyles.labelMedium.copyWith(color: textColor(context)),
      ),
    );
  }
}
