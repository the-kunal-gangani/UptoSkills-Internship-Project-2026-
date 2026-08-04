import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: context.textStyles.heading3),

          if (actionText != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                actionText!,
                style: context.textStyles.labelBold.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
