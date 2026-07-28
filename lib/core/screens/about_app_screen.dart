import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

/// Shared across all roles — shows app version, credits, etc.
class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('About App', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Logo / brand
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppGradients.coralButton,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.button,
              ),
              child: Icon(Icons.child_care_rounded, color: context.colors.white, size: 48),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('TinySteps', style: context.textStyles.heading1),
            const SizedBox(height: AppSpacing.xs),
            Text('DayCare+', style: context.textStyles.bodyMuted),
            const SizedBox(height: AppSpacing.sm),

          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? 'Loading...';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text('Version $version (MVP)', style: context.textStyles.caption.copyWith(color: context.colors.primary, fontWeight: FontWeight.w600)),
              );
            }
          ),

          const SizedBox(height: AppSpacing.xxl),

          _InfoTile(icon: Icons.info_outline, title: 'Built by', value: 'TinySteps Internship Team – 2026'),
          Divider(height: 1, color: context.colors.divider),
          _InfoTile(icon: Icons.code, title: 'Stack', value: 'Flutter + Supabase'),
          Divider(height: 1, color: context.colors.divider),
          _InfoTile(icon: Icons.mail_outline, title: 'Support', value: 'support@tinysteps.in'),
          Divider(height: 1, color: context.colors.divider),
          _InfoTile(icon: Icons.gavel_outlined, title: 'Terms & Privacy', value: 'tinysteps.in/legal'),

            const SizedBox(height: AppSpacing.xxl),
            Text('© 2026 TinySteps. All rights reserved.', style: context.textStyles.caption, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Text(title, style: context.textStyles.labelBold),
          const Spacer(),
          Text(value, style: context.textStyles.bodyMuted),
        ],
      ),
    );
  }
}
