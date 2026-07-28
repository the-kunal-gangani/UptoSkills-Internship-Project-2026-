import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinysteps/controllers/referral_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/models/referral_code_model.dart';

class ReferralCodesScreen extends ConsumerWidget {
  const ReferralCodesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(referralControllerProvider);
    final ctrl = ref.read(referralControllerProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Referral Codes', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Generate Code',
            onPressed: () => _showGenerateDialog(context, ctrl),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: ctrl.loadCodes,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.codes.isEmpty
            ? _EmptyState(onGenerate: () => _showGenerateDialog(context, ctrl))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                itemCount: state.codes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final code = state.codes[index];
                  return _ReferralCodeCard(code: code, ctrl: ctrl);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateDialog(context, ctrl),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Generate'),
      ),
    );
  }

  Future<void> _showGenerateDialog(
    BuildContext context,
    ReferralController ctrl,
  ) async {
    final role = ValueNotifier<String>('teacher');
    final days = ValueNotifier<int>(30);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Generate Referral Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose the role and expiry period.'),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: role.value,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'parent', child: Text('Parent')),
                ],
                onChanged: (value) => role.value = value ?? 'teacher',
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<int>(
                initialValue: days.value,
                decoration: const InputDecoration(labelText: 'Expiry'),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7 Days')),
                  DropdownMenuItem(value: 30, child: Text('30 Days')),
                  DropdownMenuItem(value: 60, child: Text('60 Days')),
                ],
                onChanged: (value) => days.value = value ?? 30,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final selectedRole = role.value;
                final selectedDays = days.value;
                final expiresAt = DateTime.now().add(
                  Duration(days: selectedDays),
                );
                final ok = await ctrl.generateCode(
                  role: selectedRole,
                  expiresAt: expiresAt,
                );
                if (!ctx.mounted) return;
                if (!context.mounted) return;
                Navigator.pop(ctx);
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Referral code generated successfully.'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to generate referral code.'),
                    ),
                  );
                }
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  const _ReferralCodeCard({required this.code, required this.ctrl});

  final ReferralCodeModel code;
  final ReferralController ctrl;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = code.expiresAt != null && code.expiresAt!.isBefore(now);
    final statusLabel = code.isUsed
        ? 'Used'
        : isExpired
        ? 'Expired'
        : code.isActive
        ? 'Unused'
        : 'Disabled';

    final color = code.isUsed
        ? context.colors.primary
        : isExpired
        ? context.colors.warning
        : code.isActive
        ? context.colors.success
        : context.colors.textMuted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  code.code,
                  style: context.textStyles.heading3.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: context.textStyles.labelBold.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Role: ${code.role.toUpperCase()}',
            style: context.textStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Created: ${code.createdAt != null ? _formatDate(code.createdAt!) : '—'}',
            style: context.textStyles.bodySmall.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          Text(
            'Expires: ${code.expiresAt != null ? _formatDate(code.expiresAt!) : '—'}',
            style: context.textStyles.bodySmall.copyWith(
              color: context.colors.textMuted,
            ),
          ),
          if (code.isUsed && code.usedBy != null)
            Text(
              'Used by: ${code.usedBy}',
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          if (code.createdBy != null)
            Text(
              'Created by: ${code.createdBy}',
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code.code));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied successfully.')),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy'),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (!code.isUsed)
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await ctrl.disableCode(code.id);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referral disabled.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.block_rounded, size: 18),
                  label: const Text('Disable'),
                ),
              const SizedBox(width: AppSpacing.sm),
              if (code.isUsed || !code.isActive || isExpired)
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete referral code?'),
                        content: const Text(
                          'This will permanently remove the referral code from the system.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;

                    final ok = await ctrl.deleteCode(code.id);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referral deleted.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    return '${value.day}/${value.month}/${value.year}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vpn_key_outlined,
              size: 56,
              color: context.colors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No referral codes yet', style: context.textStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Generate the first referral code for your staff.',
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Generate Code'),
            ),
          ],
        ),
      ),
    );
  }
}
