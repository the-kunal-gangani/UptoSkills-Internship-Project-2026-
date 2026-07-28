import 'package:flutter/material.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
/// Shared across all roles — Help Center, call daycare, email, FAQ.
/// Navigate here via context.push('/support') from any settings screen.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Help & Support', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help?', style: context.textStyles.heading3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Reach out to the daycare team through any of the options below.',
              style: context.textStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.xl),

            _SupportCard(
              icon: Icons.phone_outlined,
              title: 'Call Daycare',
              subtitle: '+91 98765 43210',
              color: context.colors.success,
              onTap: () async {
                final Uri url = Uri(scheme: 'tel', path: '+919876543210');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _SupportCard(
              icon: Icons.mail_outline_rounded,
              title: 'Email Support',
              subtitle: 'support@tinysteps.in',
              color: context.colors.primary,
              onTap: () async {
                final Uri url = Uri(scheme: 'mailto', path: 'support@tinysteps.in');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _SupportCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'WhatsApp',
              subtitle: 'Message us on WhatsApp',
              color: context.colors.success,
              onTap: () async {
                final Uri url = Uri.parse('https://wa.me/919876543210');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _SupportCard(
              icon: Icons.help_outline_rounded,
              title: 'FAQs',
              subtitle: 'Answers to common questions',
              color: context.colors.secondary,
              onTap: () {
                context.push('/faq');
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Office hours info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.primaryLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: context.colors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.access_time_rounded,
                      color: context.colors.primary, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Office Hours',
                            style: context.textStyles.labelBold
                                .copyWith(color: context.colors.primary)),
                        const SizedBox(height: 2),
                        Text('Mon – Sat: 8:00 AM – 6:00 PM',
                            style: context.textStyles.bodySmall),
                        Text('Sunday: Closed',
                            style: context.textStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.colors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textStyles.labelBold),
                  const SizedBox(height: 2),
                  Text(subtitle, style: context.textStyles.bodyMuted),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: context.colors.textMuted),
          ],
        ),
      ),
    );
  }
}
