import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/Controllers/parent_profile_controller.dart';
import 'package:tinysteps/Views/tinysteps/auth/screens/change_password_screen.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/core/widgets/logout_dialog.dart';

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  Future<void> _showEditDialog(
    BuildContext context,
    ParentProfileState state,
    ParentProfileController ctrl,
  ) async {
    final nameCtrl = TextEditingController(text: state.fullName);
    final phoneCtrl = TextEditingController(text: state.phone);
    final addressCtrl = TextEditingController(text: state.address);
    final emgNameCtrl = TextEditingController(text: state.emergencyContactName);
    final emgPhoneCtrl = TextEditingController(
      text: state.emergencyContactPhone,
    );
    final relCtrl = TextEditingController(text: state.relationship);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text('Edit Profile', style: context.textStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputField(context, nameCtrl, 'Full Name', Icons.person_outline),
              const SizedBox(height: AppSpacing.sm),
              _inputField(
                context,
                phoneCtrl,
                'Phone',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.sm),
              _inputField(
                context,
                relCtrl,
                'Relationship to Child',
                Icons.family_restroom,
              ),
              const SizedBox(height: AppSpacing.sm),
              _inputField(
                context,
                addressCtrl,
                'Home Address',
                Icons.home_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Emergency Contact',
                  style: context.textStyles.labelBold.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _inputField(
                context,
                emgNameCtrl,
                'Contact Name',
                Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.sm),
              _inputField(
                context,
                emgPhoneCtrl,
                'Contact Phone',
                Icons.contact_phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: context.textStyles.labelBold.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.buttonRadius,
              ),
            ),
            onPressed: () async {
              final ok = await ctrl.updateProfile(
                fullName: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                address: addressCtrl.text.trim(),
                relationship: relCtrl.text.trim(),
                emergencyContactName: emgNameCtrl.text.trim(),
                emergencyContactPhone: emgPhoneCtrl.text.trim(),
              );
              if (ctx.mounted && ok) Navigator.pop(ctx);
            },
            child: Text('Save', style: context.textStyles.buttonLabel),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    BuildContext context,
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: context.textStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: context.textStyles.labelMedium,
        prefixIcon: Icon(icon, color: context.colors.primary, size: 20),
        filled: true,
        fillColor: context.colors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: context.colors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parentProfileProvider);
    final ctrl = ref.read(parentProfileProvider.notifier);
    final initial = state.fullName.isNotEmpty
        ? state.fullName[0].toUpperCase()
        : 'P';

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : CustomScrollView(
              slivers: [
                // ── Coral gradient header ────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppGradients.coralButton,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.xl),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'My Account',
                                  style: context.textStyles.heading2.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () =>
                                      _showEditDialog(context, state, ctrl),
                                  icon: Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: context.colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: context.colors.white.withValues(
                                      alpha: 0.25,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: context.textStyles.heading1
                                          .copyWith(
                                            color: context.colors.white,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.fullName.isNotEmpty
                                            ? state.fullName
                                            : 'Parent',
                                        style: context.textStyles.heading3
                                            .copyWith(
                                              color: context.colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        state.email,
                                        style: context.textStyles.bodySmall
                                            .copyWith(
                                              color: context.colors.white
                                                  .withValues(alpha: 0.85),
                                            ),
                                      ),
                                      if (state.relationship.isNotEmpty) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        _roleBadge(context, state.relationship),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.child_care_rounded,
                                    color: context.colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    '${state.childrenCount} enrolled '
                                    '${state.childrenCount == 1 ? 'child' : 'children'}',
                                    style: context.textStyles.labelBold
                                        .copyWith(color: context.colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Body ─────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _infoCard(
                        context,
                        children: [
                          if (state.phone.isNotEmpty) ...[
                            _infoRow(
                              context,
                              Icons.phone_outlined,
                              'Phone',
                              state.phone,
                            ),
                            Divider(
                              height: AppSpacing.lg,
                              color: context.colors.border,
                            ),
                          ],
                          if (state.address.isNotEmpty) ...[
                            _infoRow(
                              context,
                              Icons.home_outlined,
                              'Address',
                              state.address,
                            ),
                            Divider(
                              height: AppSpacing.lg,
                              color: context.colors.border,
                            ),
                          ],
                          if (state.emergencyContactName.isNotEmpty) ...[
                            _infoRow(
                              context,
                              Icons.person_outline,
                              'Emergency Contact',
                              state.emergencyContactName,
                            ),
                            Divider(
                              height: AppSpacing.lg,
                              color: context.colors.border,
                            ),
                            _infoRow(
                              context,
                              Icons.contact_phone_outlined,
                              'Emergency Phone',
                              state.emergencyContactPhone,
                            ),
                          ],
                          if (state.phone.isEmpty &&
                              state.emergencyContactName.isEmpty)
                            _infoRow(
                              context,
                              Icons.info_outline,
                              'Profile',
                              'Tap edit to update your details',
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _sectionLabel(context, 'Preferences'),
                      _settingsTile(
                        context,
                        icon: Icons.child_care_rounded,
                        iconColor: context.colors.primary,
                        title: 'My Children',
                        subtitle: 'Manage enrolled children',
                        onTap: () => context.push('/parent/children'),
                      ),
                      _settingsTile(
                        context,
                        icon: Icons.notifications_none_rounded,
                        iconColor: context.colors.accent,
                        title: 'Push Notifications',
                        subtitle: 'Attendance & pickup alerts',
                        onTap: () => context.push('/notifications'),
                      ),
                      _settingsTile(
                        context,
                        icon: Icons.settings_outlined,
                        iconColor: context.colors.info,
                        title: 'App Settings',
                        subtitle: 'Appearance and language',
                        onTap: () => context.push('/app-settings'),
                      ),

                      _sectionLabel(context, 'Support & Legal'),
                      _settingsTile(
                        context,
                        icon: Icons.help_outline_rounded,
                        iconColor: context.colors.primary,
                        title: 'Help & Support',
                        onTap: () => context.push('/support'),
                      ),
                      _settingsTile(
                        context,
                        icon: Icons.verified_user_outlined,
                        iconColor: context.colors.info,
                        title: 'Pickup Authorization',
                        subtitle: 'Who can pick up your child',
                        onTap: () {},
                      ),
                      _settingsTile(
                        context,
                        icon: Icons.description_outlined,
                        iconColor: context.colors.textMuted,
                        title: 'Privacy Policy',
                        onTap: () => context.push('/privacy-policy'),
                      ),
                      _settingsTile(
                        context,
                        icon: Icons.info_outline_rounded,
                        iconColor: context.colors.textMuted,
                        title: 'About TinySteps',
                        subtitle: 'v1.0.0 · Sunrise Edition',
                        onTap: () => context.push('/about'),
                      ),

                      _sectionLabel(context, 'Account'),
                      _settingsTile(
                        context,
                        icon: Icons.lock_outline_rounded,
                        iconColor: context.colors.warning,
                        title: 'Change Password',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        ),
                      ),

                      _dangerTile(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        onTap: () async {
                          final ok = await showLogoutDialog(context);
                          if (ok) await ctrl.signOut();
                        },
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _roleBadge(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: context.colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: context.colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: context.textStyles.caption.copyWith(
          color: context.colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: context.colors.primary, size: 16),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.textStyles.caption),
              Text(value, style: context.textStyles.labelBold),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: context.textStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: context.colors.textMuted,
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border.withValues(alpha: 0.6)),
        boxShadow: AppShadows.card,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: context.textStyles.bodyLarge),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.textMuted,
                ),
              )
            : null,
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.textMuted,
              size: 20,
            ),
        onTap: onTap,
      ),
    );
  }

  Widget _dangerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.dangerLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.colors.danger.withValues(alpha: 0.25),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: context.colors.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: context.colors.danger, size: 20),
        ),
        title: Text(
          title,
          style: context.textStyles.bodyLarge.copyWith(
            color: context.colors.danger,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: context.colors.danger,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
