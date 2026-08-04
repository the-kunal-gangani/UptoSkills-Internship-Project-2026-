import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tinysteps/controllers/eduera/auth_controller.dart';

// ── EduEra Colors ─────────────────────────────────────────────────────────────
const _kBlue = Color(0xFF1565C0);
const _kBlueDark = Color(0xFF0D47A1);
const _kBlueLite = Color(0xFFE3F2FD);
const _kBlueAccent = Color(0xFF1976D2);
const _kBg = Color(0xFFF8FAFF);
const _kSurface = Color(0xFFFFFFFF);
const _kText = Color(0xFF1A1A2E);
const _kMuted = Color(0xFF6B7280);
const _kBorder = Color(0xFFDDE3F0);

class EduEraRegisterScreen extends ConsumerWidget {
  const EduEraRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eduEraAuthProvider);
    final ctrl = ref.read(eduEraAuthProvider.notifier);

    // Handle snackbars
    ref.listen(eduEraAuthProvider, (prev, next) {
      if (next.activeSnackbar != EduEraAuthSnackbar.none &&
          next.snackbarMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.snackbarMessage!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ctrl.clearSnackbar();
      }
      if (next.activeDialog == EduEraAuthDialog.emailInUse) {
        _showEmailInUseDialog(context, ctrl);
      }
    });

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state, ctrl),
            _buildStepIndicator(state),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStep(context, state, ctrl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    EduEraAuthState state,
    EduEraAuthController ctrl,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kBlue, _kBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          if (state.currentStep > 0)
            GestureDetector(
              onTap: ctrl.previousStep,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                state.currentStep == 0
                    ? 'Choose your role'
                    : state.currentStep == 1
                    ? 'Basic information'
                    : 'Almost there!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'EduEra',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Indicator ─────────────────────────────────────────────────────────
  Widget _buildStepIndicator(EduEraAuthState state) {
    return Container(
      color: _kBlueDark,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = state.currentStep == i;
          final isComplete = state.currentStep > i;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: isActive || isComplete
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step Router ────────────────────────────────────────────────────────────
  Widget _buildStep(
    BuildContext context,
    EduEraAuthState state,
    EduEraAuthController ctrl,
  ) {
    return switch (state.currentStep) {
      0 => _Step1Role(key: const ValueKey(0), ctrl: ctrl, state: state),
      1 => _Step2BasicInfo(key: const ValueKey(1), ctrl: ctrl, state: state),
      2 => _Step3RoleInfo(
        key: const ValueKey(2),
        ctrl: ctrl,
        state: state,
        context: context,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  // ── Email in use dialog ────────────────────────────────────────────────────
  void _showEmailInUseDialog(BuildContext context, EduEraAuthController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Email Already Registered',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This email is already registered. Please login instead.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.clearDialog();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kBlue),
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.clearDialog();
              context.go('/eduera/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
}

// ── Step 1 — Role Selection ───────────────────────────────────────────────────
class _Step1Role extends ConsumerWidget {
  final EduEraAuthController ctrl;
  final EduEraAuthState state;
  const _Step1Role({super.key, required this.ctrl, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'I am a...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _kText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your role to get started',
            style: TextStyle(fontSize: 14, color: _kMuted),
          ),
          const SizedBox(height: 32),

          _RoleCard(
            icon: Icons.school_rounded,
            title: 'Teacher',
            subtitle: 'Upload notes, mark attendance, enter grades',
            color: _kBlue,
            isSelected: state.selectedRole == EduEraRole.teacher,
            onTap: () => ctrl.setRole(EduEraRole.teacher),
          ),
          const SizedBox(height: 16),
          _RoleCard(
            icon: Icons.person_rounded,
            title: 'Student',
            subtitle: 'View notes, track attendance and grades',
            color: const Color(0xFF00897B),
            isSelected: state.selectedRole == EduEraRole.student,
            onTap: () => ctrl.setRole(EduEraRole.student),
          ),
          const SizedBox(height: 16),
          _RoleCard(
            icon: Icons.family_restroom_rounded,
            title: 'Parent',
            subtitle: 'Track your child\'s progress and attendance',
            color: const Color(0xFF6A1B9A),
            isSelected: state.selectedRole == EduEraRole.parent,
            onTap: () => ctrl.setRole(EduEraRole.parent),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: ctrl.nextStep,
              style: FilledButton.styleFrom(
                backgroundColor: _kBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => context.go('/eduera/login'),
              child: RichText(
                text: const TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: _kMuted, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                        color: _kBlue,
                        fontWeight: FontWeight.bold,
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
}

// ── Step 2 — Basic Info ───────────────────────────────────────────────────────
class _Step2BasicInfo extends ConsumerWidget {
  final EduEraAuthController ctrl;
  final EduEraAuthState state;
  const _Step2BasicInfo({super.key, required this.ctrl, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: ctrl.step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _kText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill in your personal details',
              style: TextStyle(fontSize: 14, color: _kMuted),
            ),
            const SizedBox(height: 28),

            _EduField(
              controller: ctrl.nameCtrl,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _EduField(
              controller: ctrl.emailCtrl,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _EduField(
              controller: ctrl.phoneCtrl,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _EduField(
              controller: ctrl.passwordCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: state.obscurePassword,
              onToggleObscure: ctrl.togglePassword,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _EduField(
              controller: ctrl.confirmCtrl,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: state.obscureConfirm,
              onToggleObscure: ctrl.toggleConfirm,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v != ctrl.passwordCtrl.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (ctrl.step2Key.currentState!.validate()) {
                    ctrl.nextStep();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _kBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 3 — Role Specific Info ───────────────────────────────────────────────
class _Step3RoleInfo extends ConsumerWidget {
  final EduEraAuthController ctrl;
  final EduEraAuthState state;
  final BuildContext context;
  const _Step3RoleInfo({
    super.key,
    required this.ctrl,
    required this.state,
    required this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: ctrl.step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              switch (state.selectedRole) {
                EduEraRole.teacher => 'Teaching Details',
                EduEraRole.student => 'Student Details',
                EduEraRole.parent => 'Link to Student',
              },
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _kText,
              ),
            ),
            const SizedBox(height: 8),
            Text(switch (state.selectedRole) {
              EduEraRole.teacher => 'Tell us about your teaching role',
              EduEraRole.student =>
                'Enter your referral code to join your class',
              EduEraRole.parent => 'Enter your child\'s email to link accounts',
            }, style: const TextStyle(fontSize: 14, color: _kMuted)),
            const SizedBox(height: 28),

            // ── Teacher fields ──────────────────────────────────
            if (state.selectedRole == EduEraRole.teacher) ...[
              _EduField(
                controller: ctrl.designationCtrl,
                label: 'Designation',
                icon: Icons.badge_outlined,
                hint: 'e.g. Professor, Lecturer, HOD',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _EduField(
                controller: ctrl.collegeNameCtrl,
                label: 'College Name',
                icon: Icons.business_outlined,
                hint: 'e.g. Pune Institute of Technology',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ],

            // ── Student fields ──────────────────────────────────
            if (state.selectedRole == EduEraRole.student) ...[
              _EduField(
                controller: ctrl.referralCtrl,
                label: 'Referral Code',
                icon: Icons.vpn_key_outlined,
                hint: 'Enter code given by your teacher',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _EduField(
                controller: ctrl.rollNumberCtrl,
                label: 'Roll Number',
                icon: Icons.format_list_numbered,
                hint: 'Your college roll number',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kBlueLite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBlue.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: _kBlue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ask your teacher for the referral code to join your class.',
                        style: TextStyle(color: _kBlue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Parent fields ───────────────────────────────────
            if (state.selectedRole == EduEraRole.parent) ...[
              _EduField(
                controller: ctrl.studentEmailCtrl,
                label: 'Student\'s Email',
                icon: Icons.email_outlined,
                hint: 'Your child\'s registered email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Required';
                  }
                  if (!v.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kBlueLite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBlue.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: _kBlue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your child must already have an EduEra student account before you register.',
                        style: TextStyle(color: _kBlue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Create Account button ───────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        if (ctrl.step3Key.currentState!.validate()) {
                          ctrl.signUp(
                            onSuccess: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Account Created! 🎉',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    state.selectedRole == EduEraRole.teacher
                                        ? 'Your account is pending admin approval. You will be able to login once approved.'
                                        : 'Your account has been created. Please verify your email and login.',
                                  ),
                                  actions: [
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _kBlue,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        ctrl.reset();
                                        context.go('/eduera/login');
                                      },
                                      child: const Text('Go to Login'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: _kBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Role Card ─────────────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : _kBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : _kText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _kMuted),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : _kBorder,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Input Field ──────────────────────────────────────────────────────
class _EduField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;

  const _EduField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: _kText, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _kMuted, fontSize: 14),
        hintStyle: TextStyle(
          color: _kMuted.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: _kBlue, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _kMuted,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: _kSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
