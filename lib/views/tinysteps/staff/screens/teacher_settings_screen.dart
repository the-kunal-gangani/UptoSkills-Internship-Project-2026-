import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/controllers/teacher_settings_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/core/widgets/logout_dialog.dart';
import 'package:tinysteps/views/tinysteps/auth/screens/change_password_screen.dart';

class TeacherSettingsScreen extends ConsumerWidget {
  const TeacherSettingsScreen({super.key});

  Future<void> _showEditProfileDialog(
    BuildContext context,
    TeacherSettingsState state,
    TeacherSettingsController ctrl,
  ) async {
    final nameCtrl = TextEditingController(text: state.fullName);
    final phoneCtrl = TextEditingController(text: state.phone);

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
              backgroundColor: context.colors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.buttonRadius,
              ),
            ),
            onPressed: () async {
              final ok = await ctrl.updateProfile(
                fullName: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
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
        prefixIcon: Icon(icon, color: context.colors.secondary, size: 20),
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
          borderSide: BorderSide(color: context.colors.secondary, width: 2),
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
    final state = ref.watch(teacherSettingsProvider);
    final ctrl = ref.read(teacherSettingsProvider.notifier);
    final initial = state.fullName.isNotEmpty
        ? state.fullName[0].toUpperCase()
        : 'S';

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.secondary),
            )
          : CustomScrollView(
              slivers: [
                // ── Lavender gradient header ─────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppGradients.lavenderAccent,
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
                                  'Settings',
                                  style: context.textStyles.heading2.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => _showEditProfileDialog(
                                    context,
                                    state,
                                    ctrl,
                                  ),
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
                                Stack(
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
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: state.isApproved
                                              ? context.colors.success
                                              : context.colors.warning,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: context.colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          state.isApproved
                                              ? Icons.check
                                              : Icons.hourglass_top_rounded,
                                          color: context.colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                            : 'Staff',
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
                                      const SizedBox(height: AppSpacing.xs),
                                      _roleBadge(
                                        context,
                                        state.isApproved
                                            ? (state.designation.isNotEmpty
                                                  ? state.designation
                                                  : 'Staff')
                                            : 'Pending Approval',
                                        state.isApproved
                                            ? context.colors.white
                                            : context.colors.warning,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                          if (state.staffId.isNotEmpty) ...[
                            _infoRow(
                              context,
                              Icons.numbers,
                              'Staff ID',
                              state.staffId,
                            ),
                            Divider(
                              height: AppSpacing.lg,
                              color: context.colors.border,
                            ),
                          ],
                          if (state.joiningDate.isNotEmpty)
                            _infoRow(
                              context,
                              Icons.calendar_today_outlined,
                              'Joined',
                              state.joiningDate,
                            ),
                          if (state.phone.isEmpty &&
                              state.staffId.isEmpty &&
                              state.joiningDate.isEmpty)
                            _infoRow(
                              context,
                              Icons.info_outline,
                              'Profile',
                              'Tap edit to update your profile',
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      _sectionLabel(context, 'Schedule & Availability'),
                      _settingsTile(
                        context,
                        icon: Icons.event_available_rounded,
                        iconColor: context.colors.primary,
                        title: 'My Availability',
                        subtitle: 'Set weekly working hours & breaks',
                        onTap: () => context.push('/teacher/availability'),
                      ),
                      _settingsTile(
                        context,
                        icon: Icons.beach_access_rounded,
                        iconColor: context.colors.secondary,
                        title: 'Leave & Holidays',
                        subtitle: 'Apply for leave or mark holidays',
                        onTap: () => context.push('/teacher/leave'),
                      ),

                      _sectionLabel(context, 'Preferences'),
                      _settingsTile(
                        context,
                        icon: Icons.notifications_none_rounded,
                        iconColor: context.colors.accent,
                        title: 'Push Notifications',
                        subtitle: 'Attendance alerts & messages',
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
                        iconColor: context.colors.secondary,
                        title: 'Help Center',
                        onTap: () => context.push('/support'),
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
                        subtitle: 'Version info & credits',
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

  Widget _roleBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: context.textStyles.caption.copyWith(
          color: color,
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
            color: context.colors.secondaryLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: context.colors.secondary, size: 16),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.textStyles.caption),
            Text(value, style: context.textStyles.labelBold),
          ],
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
