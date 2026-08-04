import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinysteps/controllers/auth_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/views/tinysteps/auth/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..forward();

  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _animCtrl,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slideAnim = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginView(fadeAnim: _fadeAnim, slideAnim: _slideAnim);
  }
}

class LoginView extends ConsumerWidget {
  const LoginView({super.key, required this.fadeAnim, required this.slideAnim});

  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  void _handleSnackbar(
    BuildContext context,
    AuthFormState state,
    AuthController ctrl,
  ) {
    if (state.activeSnackbar == AuthSnackbar.none) return;

    final color = state.activeSnackbar == AuthSnackbar.resendSuccess
        ? context.colors.success
        : context.colors.danger;

    final icon = state.activeSnackbar == AuthSnackbar.resendSuccess
        ? Icons.check_circle_outline
        : state.activeSnackbar == AuthSnackbar.networkError
        ? Icons.wifi_off_rounded
        : Icons.block_rounded;

    final message = state.activeSnackbar == AuthSnackbar.resendSuccess
        ? 'Verification email resent! Check your inbox.'
        : state.activeSnackbar == AuthSnackbar.resendFail
        ? 'Could not resend. Try again in a moment.'
        : state.snackbarMessage ?? 'Something went wrong.';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          duration: const Duration(seconds: 4),
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
      final cs = Theme.of(context).colorScheme;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark
              ? context.colors.bgDarkSurface
              : context.colors.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          icon: Icon(
            Icons.help_outline_rounded,
            color: context.colors.primary,
            size: 36,
          ),
          title: Text(
            'Couldn\'t sign you in',
            style: context.textStyles.heading3.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'The email or password is incorrect, or no account exists with this email.\n\nNew here?',
            style: context.textStyles.bodyMedium.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Try again',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/register');
              },
              child: const Text('Create account'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _handleSnackbar(context, state, ctrl);
    _handleDialog(context, state, ctrl);

    ref.listen(authControllerProvider, (_, _) {});
    ctrl.listenToAuthState(onAuthenticated: (route) => context.go(route));

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(
                  alpha: isDark ? 0.10 : 0.16,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.secondary.withValues(
                  alpha: isDark ? 0.08 : 0.12,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: FadeTransition(
                opacity: fadeAnim,
                child: SlideTransition(
                  position: slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => LinearGradient(
                              colors: [
                                context.colors.primary,
                                context.colors.secondary,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(b),
                            child: Text(
                              'TinySteps',
                              style: GoogleFonts.lexend(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            height: 3,
                            width: 48,
                            decoration: BoxDecoration(
                              gradient: AppGradients.coralButton,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Every morning is a new adventure',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: state.showVerifyBanner
                            ? _VerifyBanner(
                                key: const ValueKey('banner'),
                                email: ctrl.emailCtrl.text.trim(),
                                onResend: ctrl.resendVerificationEmail,
                                onDismiss: ctrl.dismissVerifyBanner,
                              )
                            : const SizedBox.shrink(key: ValueKey('no-banner')),
                      ),
                      if (state.showVerifyBanner)
                        const SizedBox(height: AppSpacing.md),
                      AbsorbPointer(
                        absorbing: state.isLoading,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: isDark
                                ? context.colors.bgDarkSurface
                                : context.colors.bgSurface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: cs.outline.withValues(alpha: 0.35),
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: context.colors.primary.withValues(
                                        alpha: 0.07,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),
                          child: Form(
                            key: ctrl.loginFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sign in',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Welcome back to TinySteps',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: cs.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AuthTextField(
                                  label: 'Email Address',
                                  hint: 'hello@tinysteps.com',
                                  controller: ctrl.emailCtrl,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Required';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Password',
                                      style: context.textStyles.labelBold
                                          .copyWith(color: cs.onSurface),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          context.push('/forgot-password'),
                                      child: Text(
                                        'Forgot?',
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              color: context.colors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: ctrl.passCtrl,
                                  obscureText: state.obscurePassword,
                                  style: TextStyle(color: cs.onSurface),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Required';
                                    }
                                    if (v.length < 8) {
                                      return 'Min 8 characters';
                                    }
                                    return null;
                                  },
                                  decoration: _passwordDec(
                                    context: context,
                                    hint: '••••••••',
                                    isDark: isDark,
                                    cs: cs,
                                    obscure: state.obscurePassword,
                                    onToggle: ctrl.toggleObscurePassword,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                AuthGradientButton(
                                  label: 'Sign In',
                                  icon: Icons.arrow_forward_rounded,
                                  onTap: state.isLoading
                                      ? null
                                      : () => ctrl.signIn(
                                          onSuccess: (route) =>
                                              context.go(route),
                                        ),
                                  loading: state.isLoading,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Center(
                                  child: GestureDetector(
                                    onTap: state.isLoading
                                        ? null
                                        : () => context.go('/register'),
                                    child: RichText(
                                      text: TextSpan(
                                        style: context.textStyles.bodySmall
                                            .copyWith(
                                              color: cs.onSurface.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                        children: [
                                          const TextSpan(
                                            text: "Don't have an account? ",
                                          ),
                                          TextSpan(
                                            text: 'Create account',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(child: _LoadingSpinner()),
            ),
        ],
      ),
    );
  }

  static InputDecoration _passwordDec({
    required BuildContext context,
    required String hint,
    required bool isDark,
    required ColorScheme cs,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: context.textStyles.bodyMuted.copyWith(
        color: cs.onSurface.withValues(alpha: 0.35),
      ),
      prefixIcon: Icon(
        Icons.lock_outline,
        color: cs.onSurface.withValues(alpha: 0.4),
        size: 20,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: cs.onSurface.withValues(alpha: 0.4),
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: isDark ? context.colors.bgDarkMuted : context.colors.bgLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.colors.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: context.colors.danger, width: 2),
      ),
    );
  }
}

class _VerifyBanner extends StatelessWidget {
  const _VerifyBanner({
    super.key,
    required this.email,
    required this.onResend,
    required this.onDismiss,
  });
  final String email;
  final VoidCallback onResend;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.accentLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.mark_email_unread_outlined,
            color: context.colors.accent,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please verify your email',
                  style: context.textStyles.labelBold.copyWith(
                    color: context.colors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'We sent a verification link to $email. Check your inbox (and spam!)',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.accent.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: onResend,
                  child: Text(
                    'Resend email',
                    style: context.textStyles.labelMedium.copyWith(
                      color: context.colors.accent,
                      decoration: TextDecoration.underline,
                      decorationColor: context.colors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              size: 18,
              color: context.colors.accent.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSpinner extends StatelessWidget {
  const _LoadingSpinner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? context.colors.bgDarkSurface : context.colors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.floating,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: context.colors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Please wait…',
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
