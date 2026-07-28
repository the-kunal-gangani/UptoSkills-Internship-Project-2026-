import 'package:flutter/material.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

/// Shows a styled logout confirmation dialog.
/// Returns [true] if the user confirmed, [false] if they cancelled.
Future<bool> showLogoutDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.colors.bgLight,
          surfaceTintColor: Colors.transparent,
          title: Text('Sign out?', style: context.textStyles.heading3),
          content: Text(
            'You will be returned to the login screen.',
            style: context.textStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: context.textStyles.labelBold
                    .copyWith(color: context.colors.textMuted),
              ),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: context.colors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign out', style: context.textStyles.buttonLabel),
            ),
          ],
        ),
      ) ??
      false;
}
