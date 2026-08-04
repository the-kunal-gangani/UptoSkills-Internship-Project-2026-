import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────
enum EduEraRole { teacher, student, parent }

enum EduEraAuthDialog { none, emailInUse, credentialError }

enum EduEraAuthSnackbar { none, genericError, networkError, invalidCode }

// ── State ─────────────────────────────────────────────────────────────────────
class EduEraAuthState {
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirm;
  final int currentStep;
  final EduEraRole selectedRole;
  final EduEraAuthDialog activeDialog;
  final EduEraAuthSnackbar activeSnackbar;
  final String? snackbarMessage;

  const EduEraAuthState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.currentStep = 0,
    this.selectedRole = EduEraRole.student,
    this.activeDialog = EduEraAuthDialog.none,
    this.activeSnackbar = EduEraAuthSnackbar.none,
    this.snackbarMessage,
  });

  EduEraAuthState copyWith({
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirm,
    int? currentStep,
    EduEraRole? selectedRole,
    EduEraAuthDialog? activeDialog,
    EduEraAuthSnackbar? activeSnackbar,
    String? snackbarMessage,
    bool clearSnackbar = false,
  }) {
    return EduEraAuthState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      currentStep: currentStep ?? this.currentStep,
      selectedRole: selectedRole ?? this.selectedRole,
      activeDialog: activeDialog ?? this.activeDialog,
      activeSnackbar: activeSnackbar ?? this.activeSnackbar,
      snackbarMessage: clearSnackbar
          ? null
          : snackbarMessage ?? this.snackbarMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────
class EduEraAuthController extends StateNotifier<EduEraAuthState> {
  EduEraAuthController() : super(const EduEraAuthState());

  final _client = Supabase.instance.client;

  // Form keys
  final step1Key = GlobalKey<FormState>();
  final step2Key = GlobalKey<FormState>();
  final step3Key = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  // Step 2 — Basic info controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  // Step 3 — Teacher controllers
  final designationCtrl = TextEditingController();
  final collegeNameCtrl = TextEditingController();

  // Step 3 — Student controllers
  final referralCtrl = TextEditingController();
  final rollNumberCtrl = TextEditingController();

  // Step 3 — Parent controllers
  final studentEmailCtrl = TextEditingController();

  // ── Navigation ─────────────────────────────────────────────────────────────
  void setRole(EduEraRole role) =>
      state = state.copyWith(selectedRole: role, currentStep: 0);

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) => state = state.copyWith(currentStep: step);

  // ── Toggle visibility ───────────────────────────────────────────────────────
  void togglePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  // ── Dialog / Snackbar ───────────────────────────────────────────────────────
  void clearDialog() =>
      state = state.copyWith(activeDialog: EduEraAuthDialog.none);

  void clearSnackbar() => state = state.copyWith(
    activeSnackbar: EduEraAuthSnackbar.none,
    clearSnackbar: true,
  );

  void _setSnackbar(EduEraAuthSnackbar s, {String? message}) =>
      state = state.copyWith(activeSnackbar: s, snackbarMessage: message);

  // ── Sign In ─────────────────────────────────────────────────────────────────
  Future<void> signIn({required void Function(String route) onSuccess}) async {
    if (!loginFormKey.currentState!.validate()) return;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _client.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final role = response.user?.userMetadata?['role'] as String? ?? '';

      final route = switch (role) {
        'college_teacher' => '/eduera/teacher',
        'college_student' => '/eduera/student',
        'college_parent' => '/eduera/parent',
        _ => null,
      };

      if (route == null) {
        await _client.auth.signOut();
        _setSnackbar(
          EduEraAuthSnackbar.genericError,
          message: 'This account is not registered for EduEra.',
        );
        return;
      }

      onSuccess(route);
    } on AuthException catch (e) {
      state = state.copyWith(
        activeDialog: EduEraAuthDialog.credentialError,
        snackbarMessage: e.message,
      );
    } catch (_) {
      _setSnackbar(
        EduEraAuthSnackbar.networkError,
        message: 'Connection error. Check your internet and try again.',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ── Sign Up ─────────────────────────────────────────────────────────────────
  Future<void> signUp({required VoidCallback onSuccess}) async {
    state = state.copyWith(isLoading: true);

    try {
      // Validate referral code for students
      if (state.selectedRole == EduEraRole.student) {
        final code = referralCtrl.text.trim();
        if (code.isEmpty) {
          _setSnackbar(
            EduEraAuthSnackbar.invalidCode,
            message: 'Referral code is required for student registration.',
          );
          return;
        }

        final now = DateTime.now().toUtc().toIso8601String();
        final referralRow = await _client
            .from('referral_codes')
            .select()
            .eq('code', code)
            .eq('role', 'college_student')
            .eq('is_active', true)
            .eq('is_used', false)
            .gt('expires_at', now)
            .maybeSingle();

        if (referralRow == null) {
          _setSnackbar(
            EduEraAuthSnackbar.invalidCode,
            message: 'Invalid, expired, or already used referral code.',
          );
          return;
        }
      }

      // Build metadata based on role
      final roleStr = switch (state.selectedRole) {
        EduEraRole.teacher => 'college_teacher',
        EduEraRole.student => 'college_student',
        EduEraRole.parent => 'college_parent',
      };

      final meta = <String, dynamic>{
        'full_name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'role': roleStr,
      };

      if (state.selectedRole == EduEraRole.teacher) {
        meta['designation'] = designationCtrl.text.trim();
        meta['college_name'] = collegeNameCtrl.text.trim();
      } else if (state.selectedRole == EduEraRole.student) {
        meta['referral_code'] = referralCtrl.text.trim();
        meta['roll_number'] = rollNumberCtrl.text.trim();
      } else if (state.selectedRole == EduEraRole.parent) {
        meta['student_email'] = studentEmailCtrl.text.trim();
      }

      await _client.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        data: meta,
      );

      // Mark referral code as used for students
      if (state.selectedRole == EduEraRole.student) {
        final userId = _client.auth.currentUser?.id;
        await _client
            .from('referral_codes')
            .update({
              'is_used': true,
              'used_by': userId,
              'used_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('code', referralCtrl.text.trim());
      }

      onSuccess();
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('already in use')) {
        state = state.copyWith(activeDialog: EduEraAuthDialog.emailInUse);
      } else {
        _setSnackbar(
          EduEraAuthSnackbar.genericError,
          message: 'Signup failed: ${e.message}',
        );
      }
    } catch (_) {
      _setSnackbar(
        EduEraAuthSnackbar.networkError,
        message: 'Connection error. Check your internet and try again.',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Reset ───────────────────────────────────────────────────────────────────
  void reset() {
    for (final c in [
      nameCtrl,
      emailCtrl,
      phoneCtrl,
      passwordCtrl,
      confirmCtrl,
      designationCtrl,
      collegeNameCtrl,
      referralCtrl,
      rollNumberCtrl,
      studentEmailCtrl,
    ]) {
      c.clear();
    }
    state = const EduEraAuthState();
  }

  @override
  void dispose() {
    for (final c in [
      nameCtrl,
      emailCtrl,
      phoneCtrl,
      passwordCtrl,
      confirmCtrl,
      designationCtrl,
      collegeNameCtrl,
      referralCtrl,
      rollNumberCtrl,
      studentEmailCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final eduEraAuthProvider =
    StateNotifierProvider<EduEraAuthController, EduEraAuthState>(
      (ref) => EduEraAuthController(),
    );
