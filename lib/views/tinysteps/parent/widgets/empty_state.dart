import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

/// A simple column with an icon and text for when a list has nothing to show yet
class EmptyState extends StatelessWidget {
  final String label;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.bgMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: context.colors.textMuted.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: context.textStyles.bodyMedium.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
