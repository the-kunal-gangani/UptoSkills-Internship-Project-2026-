import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tinysteps/controllers/auth_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';
import 'package:tinysteps/views/auth/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();

  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _animCtrl,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slideAnim = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

  void _animateStep() {
    _animCtrl.reset();
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterView(
      fadeAnim: _fadeAnim,
      slideAnim: _slideAnim,
      onStepChange: _animateStep,
    );
  }
}

class RegisterView extends ConsumerWidget {
  const RegisterView({
    super.key,
    required this.fadeAnim,
    required this.slideAnim,
    required this.onStepChange,
  });

  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final VoidCallback onStepChange;

  void _handleSnackbar(
    BuildContext context,
    AuthFormState state,
    AuthController ctrl,
  ) {
    if (state.activeSnackbar == AuthSnackbar.none) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.snackbarMessage ?? 'Something went wrong.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: context.colors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.md),
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
      final cs = Theme.of(context).colorScheme;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark
              ? context.colors.bgDarkSurface
              : context.colors.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          icon: Icon(
            Icons.email_outlined,
            color: context.colors.primary,
            size: 36,
          ),
          title: Text(
            'Email already registered',
            style: context.textStyles.heading3.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'An account with this email already exists. Did you mean to sign in instead?',
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
                'Stay here',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.55)),
              ),
            ),
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
                context.go('/login');
              },
              child: const Text('Sign in instead'),
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
    final totalSteps = state.selectedRole == 'parent' ? 4 : 3;

    _handleSnackbar(context, state, ctrl);
    _handleDialog(context, state, ctrl);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.secondary.withValues(
                  alpha: isDark ? 0.08 : 0.10,
                ),
              ),
            ),
          ),

          SafeArea(
            child: AbsorbPointer(
              absorbing: state.isLoading,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          color: cs.onSurface,
                          onPressed: () {
                            if (state.currentStep > 0) {
                              ctrl.previousStep();
                              onStepChange();
                            } else {
                              context.go('/login');
                            }
                          },
                        ),
                        const Spacer(),
                        if (state.currentStep > 0)
                          _StepIndicator(
                            current: state.currentStep,
                            total: totalSteps,
                          ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: FadeTransition(
                        opacity: fadeAnim,
                        child: SlideTransition(
                          position: slideAnim,
                          child: _buildStep(context, ctrl, state, isDark, cs),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (state.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.18),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark
                        ? context.colors.bgDarkSurface
                        : context.colors.bgSurface,
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
                        'Setting up your account…',
                        style: context.textStyles.bodyMedium.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    AuthController ctrl,
    AuthFormState state,
    bool isDark,
    ColorScheme cs,
  ) {
    switch (state.currentStep) {
      case 0:
        return _RoleSelectionStep(
          ctrl: ctrl,
          state: state,
          isDark: isDark,
          cs: cs,
          onSelect: (role) {
            ctrl.setRole(role);
            ctrl.goToStep(1);
            onStepChange();
          },
          onLogin: () => context.go('/login'),
        );
      case 1:
        return _LoginStep(
          ctrl: ctrl,
          state: state,
          isDark: isDark,
          cs: cs,
          onNext: () {
            if (ctrl.step1Key.currentState!.validate()) {
              ctrl.goToStep(2);
              onStepChange();
            }
          },
        );
      case 2:
        return _ProfileStep(
          ctrl: ctrl,
          state: state,
          isDark: isDark,
          cs: cs,
          onNext: () {
            if (ctrl.step2Key.currentState!.validate()) {
              if (state.selectedRole == 'parent') {
                ctrl.goToStep(3);
                onStepChange();
              } else {
                ctrl.signUp(
                  onSuccess: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Account created! Check your email to verify.',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: context.colors.success,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                    context.go('/login');
                  },
                );
              }
            }
          },
        );
      case 3:
        return _ChildInfoStep(
          ctrl: ctrl,
          state: state,
          isDark: isDark,
          cs: cs,
          onPickDob: () => ctrl.pickChildDob(context),
          onGenderChange: (v) => ctrl.setChildGender(v!),
          onSubmit: () {
            if (ctrl.step3Key.currentState!.validate()) {
              if (state.childDob == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Please select your child\'s date of birth.',
                    ),
                    backgroundColor: context.colors.danger,
                  ),
                );
                return;
              }
              ctrl.signUp(
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Account created! Check your email to verify.',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: context.colors.success,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                  context.go('/login');
                },
              );
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _RoleSelectionStep extends StatefulWidget {
  const _RoleSelectionStep({
    required this.ctrl,
    required this.state,
    required this.isDark,
    required this.cs,
    required this.onSelect,
    required this.onLogin,
  });
  final AuthController ctrl;
  final AuthFormState state;
  final bool isDark;
  final ColorScheme cs;
  final void Function(String) onSelect;
  final VoidCallback onLogin;

  @override
  State<_RoleSelectionStep> createState() => _RoleSelectionStepState();
}

class _RoleSelectionStepState extends State<_RoleSelectionStep> {
  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [context.colors.primary, context.colors.secondary],
          ).createShader(b),
          child: Text(
            'Create account',
            style: GoogleFonts.lexend(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Welcome — let\'s get you set up',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _ParentHeroCard(
          isDark: isDark,
          cs: cs,
          onTap: () => widget.onSelect('parent'),
        ),
        const SizedBox(height: AppSpacing.xl),

        Center(
          child: GestureDetector(
            onTap: widget.ctrl.toggleStaffOptions,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.state.showStaffOptions
                      ? 'Hide staff options'
                      : 'Are you staff?',
                  style: context.textStyles.bodySmall.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.45),
                    decoration: TextDecoration.underline,
                    decorationColor: cs.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  widget.state.showStaffOptions
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: cs.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState: widget.state.showStaffOptions
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: context.colors.accent.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: context.colors.accent.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Staff accounts require a referral code from the center.',
                          style: context.textStyles.bodySmall.copyWith(
                            color: context.colors.accent.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _CompactRoleCard(
                  icon: Icons.school_rounded,
                  title: 'Teacher / Staff',
                  subtitle: 'I work at the daycare',
                  color: context.colors.secondary,
                  isDark: isDark,
                  onTap: () => widget.onSelect('teacher'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Center(
          child: GestureDetector(
            onTap: widget.onLogin,
            child: RichText(
              text: TextSpan(
                style: context.textStyles.bodySmall.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                children: [
                  const TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _LoginStep extends StatelessWidget {
  const _LoginStep({
    required this.ctrl,
    required this.state,
    required this.isDark,
    required this.cs,
    required this.onNext,
  });
  final AuthController ctrl;
  final AuthFormState state;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: ctrl.step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'Create login',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter your email and a secure password',
            style: AppTextStyles.bodyMuted.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            label: 'Email Address',
            hint: 'jane@example.com',
            controller: ctrl.emailCtrl,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          AuthTextField(
            label: 'Password',
            hint: '8+ characters',
            controller: ctrl.passCtrl,
            icon: Icons.lock_outline_rounded,
            obscureText: state.obscurePass,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < 8) return 'Min 8 characters';
              return null;
            },
            suffix: IconButton(
              icon: Icon(
                state.obscurePass
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
              onPressed: ctrl.toggleObscurePass,
            ),
          ),
          AuthTextField(
            label: 'Confirm Password',
            hint: 'Re-enter password',
            controller: ctrl.confirmCtrl,
            icon: Icons.lock_outline_rounded,
            obscureText: state.obscureConfirm,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v != ctrl.passCtrl.text) return "Passwords don't match";
              return null;
            },
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
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthGradientButton(
            label: 'Next: Personal info',
            icon: Icons.arrow_forward_rounded,
            onTap: onNext,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ProfileStep extends StatefulWidget {
  const _ProfileStep({
    required this.ctrl,
    required this.state,
    required this.isDark,
    required this.cs,
    required this.onNext,
  });
  final AuthController ctrl;
  final AuthFormState state;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onNext;

  @override
  State<_ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<_ProfileStep> {
  final _phoneDigitsCtrl = TextEditingController();
  final _emergencyPhoneDigitsCtrl = TextEditingController();

  static const _relationOptions = [
    'mother',
    'father',
    'guardian',
    'grandmother',
    'grandfather',
    'uncle',
    'aunt',
    'other',
  ];
  static const _teacherDesigOptions = [
    'caregiver',
    'senior caregiver',
    'babysitter',
    'nanny',
    'special needs carer',
    'coordinator',
    'other',
  ];
  static const _adminDesigOptions = [
    'center director',
    'manager',
    'owner',
    'administrator',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.ctrl.phoneCtrl.text;
    if (existing.startsWith('+91')) {
      _phoneDigitsCtrl.text = existing.substring(3);
    }
    final existingEmg = widget.ctrl.emergencyPhoneCtrl.text;
    if (existingEmg.startsWith('+91')) {
      _emergencyPhoneDigitsCtrl.text = existingEmg.substring(3);
    }
    _phoneDigitsCtrl.addListener(_syncPhone);
    _emergencyPhoneDigitsCtrl.addListener(_syncEmergencyPhone);
  }

  void _syncPhone() =>
      widget.ctrl.phoneCtrl.text = '+91${_phoneDigitsCtrl.text.trim()}';

  void _syncEmergencyPhone() => widget.ctrl.emergencyPhoneCtrl.text =
      '+91${_emergencyPhoneDigitsCtrl.text.trim()}';

  @override
  void dispose() {
    _phoneDigitsCtrl.removeListener(_syncPhone);
    _emergencyPhoneDigitsCtrl.removeListener(_syncEmergencyPhone);
    _phoneDigitsCtrl.dispose();
    _emergencyPhoneDigitsCtrl.dispose();
    super.dispose();
  }

  String _cap(String v) => v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);
  String? _req(String? v) => v == null || v.isEmpty ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    final state = widget.state;
    final cs = widget.cs;
    final isDark = widget.isDark;

    return Form(
      key: ctrl.step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text('Your details', style: context.textStyles.heading2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Fill in your account information',
            style: context.textStyles.bodyMuted.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          AuthTextField(
            label: 'Full Name',
            hint: 'Jane Smith',
            controller: ctrl.nameCtrl,
            icon: Icons.person_outline_rounded,
            validator: _req,
          ),

          _PhoneField(
            label: 'Phone Number',
            digitsCtrl: _phoneDigitsCtrl,
            isDark: isDark,
            cs: cs,
          ),

          if (state.selectedRole != 'parent')
            AuthTextField(
              label: 'Referral Code',
              hint: 'TINY-XXXX (from your admin)',
              controller: ctrl.referralCtrl,
              icon: Icons.vpn_key_outlined,
              validator: _req,
            ),

          if (state.selectedRole == 'parent') ...[
            const _Divider('Emergency contact'),
            AuthTextField(
              label: 'Contact Name',
              hint: 'John Smith',
              controller: ctrl.emergencyNameCtrl,
              icon: Icons.contact_emergency_outlined,
              validator: _req,
            ),
            _PhoneField(
              label: 'Contact Phone',
              digitsCtrl: _emergencyPhoneDigitsCtrl,
              isDark: isDark,
              cs: cs,
            ),
            _DropdownField<String>(
              label: 'Relationship to Child',
              icon: Icons.people_outline_rounded,
              value: state.relation,
              options: _relationOptions,
              displayLabel: _cap,
              isDark: isDark,
              cs: cs,
              onChanged: (v) => ctrl.setRelation(v!),
            ),
            if (state.relationOther)
              AuthTextField(
                label: 'Specify relationship',
                hint: 'e.g. Step-parent, Sibling...',
                controller: ctrl.relationCtrl,
                icon: Icons.edit_outlined,
                validator: _req,
              ),
          ],

          if (state.selectedRole == 'teacher') ...[
            const _Divider('Professional details'),
            AuthTextField(
              label: 'Staff ID',
              hint: 'EMP-1234 (optional)',
              controller: ctrl.staffIdCtrl,
              icon: Icons.badge_outlined,
            ),
            _DropdownField<String>(
              label: 'Designation',
              icon: Icons.work_outline_rounded,
              value: state.teacherDesig,
              options: _teacherDesigOptions,
              displayLabel: _cap,
              isDark: isDark,
              cs: cs,
              onChanged: (v) => ctrl.setTeacherDesig(v!),
            ),
            if (state.teacherDesigOther)
              AuthTextField(
                label: 'Specify designation',
                hint: 'e.g. Therapist, Nurse...',
                controller: ctrl.designationCtrl,
                icon: Icons.edit_outlined,
                validator: _req,
              ),
          ],

          if (state.selectedRole == 'admin') ...[
            const _Divider('Center details'),
            AuthTextField(
              label: 'Center Name',
              hint: 'Little Stars Daycare',
              controller: ctrl.centerNameCtrl,
              icon: Icons.business_outlined,
              validator: _req,
            ),
            _DropdownField<String>(
              label: 'Your Designation',
              icon: Icons.manage_accounts_outlined,
              value: state.adminDesig,
              options: _adminDesigOptions,
              displayLabel: _cap,
              isDark: isDark,
              cs: cs,
              onChanged: (v) => ctrl.setAdminDesig(v!),
            ),
            if (state.adminDesigOther)
              AuthTextField(
                label: 'Specify designation',
                hint: 'e.g. Co-founder, Supervisor...',
                controller: ctrl.adminDesigCtrl,
                icon: Icons.edit_outlined,
                validator: _req,
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AuthGradientButton(
            label: state.selectedRole == 'parent'
                ? 'Next: Add child info'
                : 'Create account',
            icon: state.selectedRole == 'parent'
                ? Icons.arrow_forward_rounded
                : Icons.check_rounded,
            onTap: state.isLoading ? null : widget.onNext,
            loading: state.isLoading,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ChildInfoStep extends StatelessWidget {
  const _ChildInfoStep({
    required this.ctrl,
    required this.state,
    required this.isDark,
    required this.cs,
    required this.onPickDob,
    required this.onGenderChange,
    required this.onSubmit,
  });
  final AuthController ctrl;
  final AuthFormState state;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onPickDob;
  final void Function(String?) onGenderChange;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: ctrl.step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.child_care_rounded,
                  color: context.colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your child's info",
                      style: context.textStyles.heading2,
                    ),
                    Text(
                      "You can add more children after sign-up",
                      style: context.textStyles.bodySmall.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthTextField(
            label: "Child's Full Name",
            hint: 'Emma Smith',
            controller: ctrl.childNameCtrl,
            icon: Icons.person_outline_rounded,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date of Birth',
                  style: context.textStyles.labelBold.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onPickDob,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? context.colors.bgDarkMuted
                          : context.colors.bgLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: cs.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.childDob != null
                              ? '${state.childDob!.day}/${state.childDob!.month}/${state.childDob!.year}'
                              : 'Select date of birth',
                          style: state.childDob != null
                              ? context.textStyles.bodyMedium.copyWith(
                                  color: cs.onSurface,
                                )
                              : context.textStyles.bodyMuted.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.35),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: context.textStyles.labelBold.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? context.colors.bgDarkMuted
                        : context.colors.bgLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.4),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: state.childGender,
                      isExpanded: true,
                      dropdownColor: isDark
                          ? context.colors.bgDarkSurface
                          : context.colors.bgSurface,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: cs.onSurface,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text('Prefer not to say'),
                        ),
                      ],
                      onChanged: onGenderChange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AuthTextField(
            label: 'Allergies',
            hint: 'None / Peanuts / Dairy... (optional)',
            controller: ctrl.allergyCtrl,
            icon: Icons.warning_amber_outlined,
          ),
          AuthTextField(
            label: 'Medical Notes',
            hint: 'Any conditions the caregiver should know (optional)',
            controller: ctrl.medCtrl,
            icon: Icons.medical_information_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthGradientButton(
            label: 'Create account',
            icon: Icons.check_rounded,
            onTap: state.isLoading ? null : onSubmit,
            loading: state.isLoading,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ParentHeroCard extends StatelessWidget {
  const _ParentHeroCard({
    required this.isDark,
    required this.cs,
    required this.onTap,
  });
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.coralButton,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.family_restroom_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join as Parent',
                        style: GoogleFonts.lexend(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enroll your child & track their day',
                        style: context.textStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactRoleCard extends StatelessWidget {
  const _CompactRoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? context.colors.bgDarkSurface
                : context.colors.bgSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 17, color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.textStyles.bodySmall.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurface.withValues(alpha: 0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.label,
    required this.digitsCtrl,
    required this.isDark,
    required this.cs,
  });
  final String label;
  final TextEditingController digitsCtrl;
  final bool isDark;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textStyles.labelBold.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? context.colors.bgDarkMuted
                      : context.colors.bgLight,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.md),
                  ),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '+91',
                      style: context.textStyles.labelBold.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: digitsCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: context.textStyles.bodyMedium.copyWith(
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '98765 43210',
                    hintStyle: context.textStyles.bodyMuted.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.35),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? context.colors.bgDarkMuted
                        : context.colors.bgLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.md),
                      ),
                      borderSide: BorderSide(
                        color: cs.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.md),
                      ),
                      borderSide: BorderSide(
                        color: cs.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.md),
                      ),
                      borderSide: BorderSide(
                        color: context.colors.primary,
                        width: 1.8,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.md),
                      ),
                      borderSide: BorderSide(color: context.colors.danger),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.md),
                      ),
                      borderSide: BorderSide(
                        color: context.colors.danger,
                        width: 1.8,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.replaceAll(RegExp(r'\D'), '').length != 10) {
                      return 'Enter 10 digits';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.displayLabel,
    required this.isDark,
    required this.cs,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final T value;
  final List<T> options;
  final String Function(T) displayLabel;
  final bool isDark;
  final ColorScheme cs;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textStyles.labelBold.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? context.colors.bgDarkMuted
                  : context.colors.bgLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      isExpanded: true,
                      dropdownColor: isDark
                          ? context.colors.bgDarkSurface
                          : context.colors.bgSurface,
                      style: context.textStyles.bodyMedium.copyWith(
                        color: cs.onSurface,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                      items: options
                          .map(
                            (o) => DropdownMenuItem<T>(
                              value: o,
                              child: Text(displayLabel(o)),
                            ),
                          )
                          .toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: cs.outline.withValues(alpha: 0.4), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              label,
              style: context.textStyles.labelMedium.copyWith(
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ),
          Expanded(
            child: Divider(color: cs.outline.withValues(alpha: 0.4), height: 1),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i < current;
        final dot = i + 1;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: active ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? context.colors.primary : context.colors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (dot < total) const SizedBox(width: 4),
          ],
        );
      }),
    );
  }
}
