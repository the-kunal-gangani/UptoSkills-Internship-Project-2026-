import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/controllers/admin_settings_controller.dart';
import 'package:tinysteps/controllers/admin_users_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/core/widgets/logout_dialog.dart';
import 'package:tinysteps/views/tinysteps/admin/screens/users_screen.dart';
import 'package:tinysteps/views/tinysteps/auth/screens/change_password_screen.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  // ── Add Admin dialog ───────────────────────────────────────────────────────
  Future<void> _showAddAdminDialog(
    BuildContext context,
    AdminUsersController usersCtrl,
  ) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final desigCtrl = TextEditingController(text: 'Center Director');
    final centerCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePass = true;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: context.colors.bgLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Add Admin', style: context.textStyles.heading3),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  _FormField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FormField(
                    controller: emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FormField(
                    controller: phoneCtrl,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FormField(
                    controller: desigCtrl,
                    label: 'Designation',
                    icon: Icons.badge_outlined,
                    hint: 'e.g. Center Director, Manager',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FormField(
                    controller: centerCtrl,
                    label: 'Center Name',
                    icon: Icons.business_outlined,
                    hint: 'e.g. TinySteps Andheri',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Password field
                  TextFormField(
                    controller: passCtrl,
                    obscureText: obscurePass,
                    style: context.textStyles.bodyMedium,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.length < 8) return 'Min 8 characters';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: context.textStyles.labelMedium,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: context.colors.primary,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: context.colors.textMuted,
                        ),
                        onPressed: () =>
                            setDialogState(() => obscurePass = !obscurePass),
                      ),
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
                        borderSide: BorderSide(
                          color: context.colors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);

                      final ok = await usersCtrl.createAdmin(
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        designation: desigCtrl.text.trim(),
                        centerName: centerCtrl.text.trim(),
                        password: passCtrl.text.trim(),
                      );

                      setDialogState(() => isSaving = false);

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Admin account created successfully'
                                  : 'Failed to create admin. Try again.',
                            ),
                            backgroundColor: ok
                                ? context.colors.success
                                : context.colors.danger,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Create Admin', style: context.textStyles.buttonLabel),
            ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    desigCtrl.dispose();
    centerCtrl.dispose();
    passCtrl.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminSettingsProvider);
    final ctrl = ref.read(adminSettingsProvider.notifier);
    final usersState = ref.watch(adminUsersProvider);
    final usersCtrl = ref.read(adminUsersProvider.notifier);

    final initial = state.fullName.isNotEmpty
        ? state.fullName[0].toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : CustomScrollView(
              slivers: [
                // ── Sunrise gradient header ──────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppGradients.sunrise,
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
                                  onPressed: () => showEditProfileDialog(
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
                                            : 'Admin',
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
                                      roleBadge(
                                        context,
                                        state.designation.isNotEmpty
                                            ? state.designation
                                            : 'Administrator',
                                        context.colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (state.centerName.isNotEmpty) ...[
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
                                      Icons.business_rounded,
                                      color: context.colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      state.centerName,
                                      style: context.textStyles.labelBold
                                          .copyWith(
                                            color: context.colors.white,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Body ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Profile info card
                      if (state.phone.isNotEmpty)
                        infoCard(
                          context,
                          children: [
                            infoRow(
                              context,
                              Icons.phone_outlined,
                              'Phone',
                              state.phone,
                            ),
                          ],
                        ),
                      if (state.phone.isNotEmpty)
                        const SizedBox(height: AppSpacing.lg),

                      // ── Admin Management section ─────────────────
                      sectionLabel(context, 'Admin Management'),
                      _buildAdminsList(context, usersState, usersCtrl),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              _showAddAdminDialog(context, usersCtrl),
                          icon: const Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 18,
                          ),
                          label: const Text('Add New Admin'),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── App Preferences ──────────────────────────
                      sectionLabel(context, 'App Preferences'),
                      settingsTile(
                        context,
                        icon: Icons.notifications_none_rounded,
                        iconColor: context.colors.accent,
                        title: 'Push Notifications',
                        subtitle: 'Alerts for attendance & messages',
                        onTap: () => context.push('/notifications'),
                      ),
                      settingsTile(
                        context,
                        icon: Icons.settings_outlined,
                        iconColor: context.colors.info,
                        title: 'App Settings',
                        subtitle: 'Appearance and language',
                        onTap: () => context.push('/app-settings'),
                      ),

                      // ── Daycare Management ────────────────────────
                      sectionLabel(context, 'Daycare Management'),
                      settingsTile(
                        context,
                        icon: Icons.security_rounded,
                        iconColor: context.colors.info,
                        title: 'Roles & Permissions',
                        subtitle: 'Control staff access',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UsersScreen(),
                          ),
                        ),
                      ),
                      settingsTile(
                        context,
                        icon: Icons.card_membership_rounded,
                        iconColor: context.colors.success,
                        title: 'Subscription',
                        subtitle: 'Manage your TinySteps plan',
                        onTap: () {},
                      ),

                      // ── Support & Legal ───────────────────────────
                      sectionLabel(context, 'Support & Legal'),
                      settingsTile(
                        context,
                        icon: Icons.help_outline_rounded,
                        iconColor: context.colors.primary,
                        title: 'Help Center & FAQ',
                        onTap: () => context.push('/support'),
                      ),
                      settingsTile(
                        context,
                        icon: Icons.description_outlined,
                        iconColor: context.colors.textMuted,
                        title: 'Privacy Policy',
                        onTap: () => context.push('/privacy-policy'),
                      ),
                      settingsTile(
                        context,
                        icon: Icons.info_outline_rounded,
                        iconColor: context.colors.textMuted,
                        title: 'About TinySteps',
                        subtitle: 'Version info & credits',
                        onTap: () => context.push('/about'),
                      ),

                      // ── Account ───────────────────────────────────
                      sectionLabel(context, 'Account'),
                      settingsTile(
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

  // ── Admins list widget ─────────────────────────────────────────────────────
  Widget _buildAdminsList(
    BuildContext context,
    AdminUsersState state,
    AdminUsersController ctrl,
  ) {
    if (state.isLoadingAdmins) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
      );
    }

    if (state.admins.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.colors.border),
        ),
        child: Text(
          'No admins found',
          style: context.textStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: List.generate(state.admins.length, (index) {
          final a = state.admins[index] as Map<String, dynamic>;
          final name = a['full_name'] as String? ?? 'Admin';
          final email = a['email'] as String? ?? '—';
          final designation = a['designation'] as String? ?? 'Administrator';
          final isActive = a['is_active'] == true;
          final isLast = index == state.admins.length - 1;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                leading: CircleAvatar(
                  backgroundColor: context.colors.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: context.textStyles.labelBold.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                title: Text(name, style: context.textStyles.labelBold),
                subtitle: Text(
                  '$designation  ·  $email',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: _StatusBadge(
                  label: isActive ? 'Active' : 'Inactive',
                  color: isActive
                      ? context.colors.success
                      : context.colors.danger,
                ),
                onTap: () => _showAdminDetail(context, a, ctrl),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: AppSpacing.lg,
                  color: context.colors.border,
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Admin detail dialog ────────────────────────────────────────────────────
  void _showAdminDetail(
    BuildContext context,
    Map<String, dynamic> admin,
    AdminUsersController ctrl,
  ) {
    final name = admin['full_name'] as String? ?? 'Admin';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    final email = admin['email'] as String? ?? '—';
    final phone = admin['phone'] as String? ?? '—';
    final designation = admin['designation'] as String? ?? 'Administrator';
    final centerName = admin['center_name'] as String? ?? '—';
    bool isActive = admin['is_active'] == true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: context.colors.bgLight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: context.colors.primary.withValues(
                    alpha: 0.15,
                  ),
                  child: Text(
                    initial,
                    style: context.textStyles.heading1.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(name, style: context.textStyles.heading3),
                const SizedBox(height: 4),
                _StatusBadge(
                  label: isActive ? 'Active' : 'Inactive',
                  color: isActive
                      ? context.colors.success
                      : context.colors.danger,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email,
                      ),
                      Divider(
                        height: AppSpacing.lg,
                        color: context.colors.border,
                      ),
                      _DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: phone,
                      ),
                      Divider(
                        height: AppSpacing.lg,
                        color: context.colors.border,
                      ),
                      _DetailRow(
                        icon: Icons.badge_outlined,
                        label: 'Designation',
                        value: designation,
                      ),
                      Divider(
                        height: AppSpacing.lg,
                        color: context.colors.border,
                      ),
                      _DetailRow(
                        icon: Icons.business_outlined,
                        label: 'Center',
                        value: centerName,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(
                      isActive
                          ? Icons.person_off_outlined
                          : Icons.person_add_alt_1,
                      size: 18,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isActive
                          ? context.colors.danger
                          : context.colors.success,
                      side: BorderSide(
                        color: isActive
                            ? context.colors.danger
                            : context.colors.success,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.buttonRadius,
                      ),
                    ),
                    onPressed: () async {
                      final ok = await ctrl.toggleAdminActive(
                        admin['id'],
                        isActive,
                      );
                      if (ctx.mounted && ok) {
                        setDialogState(() => isActive = !isActive);
                      }
                    },
                    label: Text(
                      isActive ? 'Deactivate Admin' : 'Activate Admin',
                      style: context.textStyles.labelBold.copyWith(
                        color: isActive
                            ? context.colors.danger
                            : context.colors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.textMedium,
                  side: BorderSide(color: context.colors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.buttonRadius,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
                child: Text('Close', style: context.textStyles.labelBold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget roleBadge(BuildContext context, String label, Color color) {
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

  Widget infoCard(BuildContext context, {required List<Widget> children}) {
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

  Widget infoRow(
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

  Widget sectionLabel(BuildContext context, String label) {
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

  Widget settingsTile(
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

  Future<void> showEditProfileDialog(
    BuildContext context,
    AdminSettingsState state,
    AdminSettingsController ctrl,
  ) async {
    final nameCtrl = TextEditingController(text: state.fullName);
    final phoneCtrl = TextEditingController(text: state.phone);
    final desigCtrl = TextEditingController(text: state.designation);
    final centerCtrl = TextEditingController(text: state.centerName);

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
              inputField(context, nameCtrl, 'Full Name', Icons.person_outline),
              const SizedBox(height: AppSpacing.sm),
              inputField(
                context,
                phoneCtrl,
                'Phone',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.sm),
              inputField(
                context,
                desigCtrl,
                'Designation',
                Icons.badge_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              inputField(
                context,
                centerCtrl,
                'Center Name',
                Icons.business_outlined,
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
              final success = await ctrl.updateProfile(
                fullName: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                designation: desigCtrl.text.trim(),
                centerName: centerCtrl.text.trim(),
              );
              if (ctx.mounted && success) Navigator.pop(ctx);
            },
            child: Text('Save', style: context.textStyles.buttonLabel),
          ),
        ],
      ),
    );
  }

  Widget inputField(
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
}

// ── Reusable form field ────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: context.textStyles.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
}

// ── Shared widgets ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: context.textStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.colors.textMuted),
        const SizedBox(width: AppSpacing.sm),
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
}
