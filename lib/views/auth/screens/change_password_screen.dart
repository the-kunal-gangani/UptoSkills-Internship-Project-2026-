import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/controllers/auth_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/views/auth/widgets/auth_widgets.dart';

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  void _handleSnackbar(
    BuildContext context,
    AuthFormState state,
    AuthController ctrl,
  ) {
    if (state.activeSnackbar == AuthSnackbar.none) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.snackbarMessage ?? 'Something went wrong.'),
          backgroundColor: context.colors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      ctrl.clearSnackbar();
    });
  }

  void _handleDialog(
    BuildContext context,
    AuthFormState state,
    AuthController ctrl,
  ) {
    if (state.activeDialog != AuthDialog.passwordUpdated) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          icon: Icon(
            Icons.check_circle_outline_rounded,
            color: context.colors.success,
            size: 40,
          ),
          title: Text(
            'Password Changed',
            style: context.textStyles.heading3,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Your password has been updated successfully.',
            style: context.textStyles.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
      ctrl.clearDialog();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final ctrl = ref.read(authControllerProvider.notifier);

    _handleSnackbar(context, state, ctrl);
    _handleDialog(context, state, ctrl);

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFFFFD4C2), context.colors.bgLight],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: context.colors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    'Change Password',
                    style: context.textStyles.heading2,
                  ),
                  centerTitle: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: context.colors.white.withValues(
                                alpha: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: context.colors.white.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: ctrl.changePassFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Update your security',
                                    style: context.textStyles.heading3,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Ensure your account stays protected with a strong password.',
                                    style: context.textStyles.bodyMuted,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  AuthTextField(
                                    label: 'Current Password',
                                    hint: 'Enter current password',
                                    controller: ctrl.currentPasswordCtrl,
                                    icon: Icons.lock_open_rounded,
                                    obscureText: state.obscureCurrentPassword,
                                    suffix: IconButton(
                                      icon: Icon(
                                        state.obscureCurrentPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                      ),
                                      onPressed:
                                          ctrl.toggleObscureCurrentPassword,
                                    ),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Required'
                                        : null,
                                  ),
                                  AuthTextField(
                                    label: 'New Password',
                                    hint: 'Minimum 6 characters',
                                    controller: ctrl.passCtrl,
                                    icon: Icons.vpn_key_outlined,
                                    obscureText: state.obscurePassword,
                                    suffix: IconButton(
                                      icon: Icon(
                                        state.obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                      ),
                                      onPressed: ctrl.toggleObscurePassword,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Required';
                                      }
                                      if (v.length < 6) {
                                        return 'At least 6 chars';
                                      }
                                      return null;
                                    },
                                  ),
                                  AuthTextField(
                                    label: 'Confirm New Password',
                                    hint: 'Repeat new password',
                                    controller: ctrl.confirmCtrl,
                                    icon: Icons.verified_user_outlined,
                                    obscureText: state.obscureConfirm,
                                    suffix: IconButton(
                                      icon: Icon(
                                        state.obscureConfirm
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                      ),
                                      onPressed: ctrl.toggleObscureConfirm,
                                    ),
                                    validator: (v) {
                                      if (v != ctrl.passCtrl.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.xxl),
                                  AuthGradientButton(
                                    label: 'Update Password',
                                    icon: Icons.check_rounded,
                                    loading: state.isLoading,
                                    onTap: state.isLoading
                                        ? null
                                        : () {
                                            if (ctrl
                                                .changePassFormKey
                                                .currentState!
                                                .validate()) {
                                              ctrl.changePassword(
                                                currentPassword: ctrl
                                                    .currentPasswordCtrl
                                                    .text
                                                    .trim(),
                                                newPassword: ctrl.passCtrl.text
                                                    .trim(),
                                                onSuccess: () {},
                                              );
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildTip(
                        context,
                        Icons.info_outline_rounded,
                        'Use a mix of letters, numbers, and symbols for a stronger password.',
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
