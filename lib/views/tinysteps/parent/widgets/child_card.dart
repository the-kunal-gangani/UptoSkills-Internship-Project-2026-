import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ChildCard extends StatelessWidget {
  final String childId;
  final String name;
  final String dob;
  final String classroom;

  const ChildCard({
    super.key,
    required this.childId,
    required this.name,
    required this.dob,
    required this.classroom,
  });

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.xl,
            ), // Sunrise 24px tokens
          ),
          backgroundColor: context.colors.bgSurface,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ), // 24px layout grid spacing
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  name,
                  style: context.textStyles.heading2.copyWith(
                    color: context.colors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Select an action below',
                  style: context.textStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Option 1: Add Activity
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        context.colors.primary, // Sunrise Cool Teal
                    foregroundColor: context.colors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close dialog

                    // Destination path for Task 3
                    context.push(
                      '/parent/add-activity?childId=$childId&name=${Uri.encodeComponent(name)}&classroom=${Uri.encodeComponent(classroom)}',
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Add activity',
                        style: context.textStyles.buttonLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Option 2: See Activity
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    side: BorderSide(color: context.colors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close dialog
                    context.push(
                      '/parent/children/$childId?name=${Uri.encodeComponent(name)}',
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bar_chart_rounded, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'See activity',
                        style: context.textStyles.buttonLabel.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: context.textStyles.labelBold.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showActionDialog(context),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: context.colors.primary.withValues(alpha: 0.15),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'C',
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.textStyles.labelBold),
                  const SizedBox(height: 2),
                  Text('DOB: $dob', style: context.textStyles.bodyMuted),
                  Text(classroom, style: context.textStyles.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
