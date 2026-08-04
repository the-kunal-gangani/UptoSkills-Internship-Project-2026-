import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/controllers/auth_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/views/tinysteps/Widgets/auth_widget.dart';

class ForgotPassScreen extends ConsumerWidget {
  const ForgotPassScreen({super.key});

  void _handleSnackbar(
    BuildContext context,
    AuthFormState state,
    AuthController ctrl,
  ) {
    if (state.activeSnackbar == AuthSnackbar.none) return;
    final isError = state.activeSnackbar != AuthSnackbar.resendSuccess;
    final message =
        state.snackbarMessage ??
        (state.activeSnackbar == AuthSnackbar.resendSuccess
            ? 'Reset link sent!'
            : 'Something went wrong.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? context.colors.danger
              : context.colors.success,
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
    if (state.activeDialog == AuthDialog.none) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isReset = state.activeDialog == AuthDialog.resetEmailSent;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(isReset ? 'Email Sent' : 'Password Updated'),
          content: Text(
            isReset
                ? 'Check your inbox for a password reset link.'
                : 'Your password has been updated. Please sign in again.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                if (!isReset) await ctrl.signOut();
                if (context.mounted) context.go('/login');
              },
              child: const Text('OK'),
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
    final cs = Theme.of(context).colorScheme;

    _handleSnackbar(context, state, ctrl);
    _handleDialog(context, state, ctrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isResetMode ? 'Reset Password' : 'Forgot Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.isResetMode
                    ? 'Create New Password'
                    : 'Reset your password',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                state.isResetMode
                    ? 'Enter your new password below.'
                    : 'Enter your email and we\'ll send you a reset link.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Form(
                key: ctrl.forgotFormKey,
                child: Column(
                  children: [
                    if (!state.isResetMode)
                      AuthTextField(
                        label: 'Email Address',
                        hint: 'hello@tinysteps.com',
                        controller: ctrl.emailCtrl,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (!v.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      )
                    else ...[
                      AuthTextField(
                        label: 'New Password',
                        hint: '••••••••',
                        controller: ctrl.passCtrl,
                        icon: Icons.lock_outline,
                        obscureText: state.obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            state.obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          onPressed: ctrl.toggleObscurePassword,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.length < 8) return 'Min 8 characters';
                          return null;
                        },
                      ),
                      AuthTextField(
                        label: 'Confirm New Password',
                        hint: '••••••••',
                        controller: ctrl.confirmCtrl,
                        icon: Icons.lock_outline,
                        obscureText: state.obscureConfirm,
                        suffix: IconButton(
                          icon: Icon(
                            state.obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          onPressed: ctrl.toggleObscureConfirm,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v != ctrl.passCtrl.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AuthGradientButton(
                      label: state.isResetMode
                          ? 'Update Password'
                          : 'Send Reset Link',
                      icon: state.isResetMode
                          ? Icons.check_circle_outline
                          : Icons.send_rounded,
                      onTap: state.isLoading
                          ? null
                          : () {
                              if (state.isResetMode) {
                                ctrl.updatePassword(onSuccess: () {});
                              } else {
                                ctrl.sendPasswordResetEmail(onSuccess: () {});
                              }
                            },
                      loading: state.isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
