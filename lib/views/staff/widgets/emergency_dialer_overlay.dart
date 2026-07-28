import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class EmergencyDialerOverlay extends StatelessWidget {
  final String parentName;
  final String parentPhone;
  final String adminName;
  final String adminPhone;

  const EmergencyDialerOverlay({
    super.key,
    required this.parentName,
    required this.parentPhone,
    required this.adminName,
    required this.adminPhone,
  });

  Future<void> _makeCall(BuildContext context, String number) async {
    if (number.isEmpty) return;
    final Uri url = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Cannot launch phone dialer for: $number'),
            backgroundColor: context.colors.danger,
          ));
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error launching dialer'),
          backgroundColor: context.colors.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(Icons.emergency_rounded, color: context.colors.danger, size: 28),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Emergency Assistance',
                style: context.textStyles.heading3.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'SOS alert has been triggered in the database. Call emergency services or contacts immediately:',
            style: context.textStyles.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Quick Dial Services (Row of circles) ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _EmergencyServiceCard(
                icon: Icons.local_police_rounded,
                label: 'Police',
                number: '100', // India (can fallback or launch dialer)
                color: Colors.blue.shade700,
                onTap: () => _makeCall(context, '100'),
              ),
              _EmergencyServiceCard(
                icon: Icons.local_hospital_rounded,
                label: 'Ambulance',
                number: '108',
                color: Colors.red.shade700,
                onTap: () => _makeCall(context, '108'),
              ),
              _EmergencyServiceCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Fire Dept',
                number: '101',
                color: Colors.orange.shade800,
                onTap: () => _makeCall(context, '101'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // ── Key Contacts ──────────────────────────────────────────
          Text('Key Contacts', style: context.textStyles.labelBold),
          const SizedBox(height: AppSpacing.md),

          // Parent Contact
          if (parentPhone.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: context.colors.primaryLight,
                child: Icon(Icons.person_rounded, color: context.colors.primary),
              ),
              title: Text('Parent: $parentName', style: context.textStyles.labelBold),
              subtitle: Text(parentPhone, style: context.textStyles.caption),
              trailing: IconButton.filledTonal(
                icon: const Icon(Icons.call_rounded),
                onPressed: () => _makeCall(context, parentPhone),
              ),
            ),

          // Admin Contact
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: context.colors.primaryLight,
              child: Icon(Icons.support_agent_rounded, color: context.colors.primary),
            ),
            title: Text('Admin / Agency', style: context.textStyles.labelBold),
            subtitle: Text(adminPhone.isNotEmpty ? adminPhone : 'Agency Dispatch'),
            trailing: adminPhone.isNotEmpty
                ? IconButton.filledTonal(
                    icon: const Icon(Icons.call_rounded),
                    onPressed: () => _makeCall(context, adminPhone),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _EmergencyServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyServiceCard({
    required this.icon,
    required this.label,
    required this.number,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.textStyles.labelBold.copyWith(color: color),
            ),
            Text(
              number,
              style: context.textStyles.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
