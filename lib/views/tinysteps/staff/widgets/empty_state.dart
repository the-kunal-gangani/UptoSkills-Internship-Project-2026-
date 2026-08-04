import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 48,
          color: context.colors.textMuted,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          style: context.textStyles.bodyMuted,
        ),
      ],
    );
  }
}
