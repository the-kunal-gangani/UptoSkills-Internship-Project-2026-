import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/models/child_model.dart';
import 'package:tinysteps/models/user_model.dart';

enum AuthDialog {
  none,
  credentialError,
  emailInUse,
  resetEmailSent,
  passwordUpdated,
}

enum AuthSnackbar {
  none,
  banned,
  networkError,
  resendSuccess,
  resendFail,
  notRegistered,
  genericError,
  pendingApproval,
}

class AuthFormState {
  final bool isLoading;
  final bool showVerifyBanner;
  final bool isResetMode;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool obscurePass;
  final bool obscureCurrentPassword;
  final bool showStaffOptions;
  final AuthDialog activeDialog;
  final AuthSnackbar activeSnackbar;
  final String? snackbarMessage;
  final int currentStep;
  final String selectedRole;
  final DateTime? childDob;
  final String childGender;
  final String relation;
  final bool relationOther;
  final String teacherDesig;
  final bool teacherDesigOther;
  final String adminDesig;
  final bool adminDesigOther;

  const AuthFormState({
    this.isLoading = false,
    this.showVerifyBanner = false,
    this.isResetMode = false,
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.obscurePass = true,
    this.obscureCurrentPassword = true,
    this.showStaffOptions = false,
    this.activeDialog = AuthDialog.none,
    this.activeSnackbar = AuthSnackbar.none,
    this.snackbarMessage,
    this.currentStep = 0,
    this.selectedRole = 'parent',
    this.childDob,
    this.childGender = 'male',
    this.relation = 'mother',
    this.relationOther = false,
    this.teacherDesig = 'caregiver',
    this.teacherDesigOther = false,
    this.adminDesig = 'owner',
    this.adminDesigOther = false,
  });

  AuthFormState copyWith({
    bool? isLoading,
    bool? showVerifyBanner,
    bool? isResetMode,
    bool? obscurePassword,
    bool? obscureConfirm,
    bool? obscurePass,
    bool? obscureCurrentPassword,
    bool? showStaffOptions,
    AuthDialog? activeDialog,
    AuthSnackbar? activeSnackbar,
    String? snackbarMessage,
    bool clearSnackbarMessage = false,
    int? currentStep,
    String? selectedRole,
    DateTime? childDob,
    bool clearChildDob = false,
    String? childGender,
    String? relation,
    bool? relationOther,
    String? teacherDesig,
    bool? teacherDesigOther,
    String? adminDesig,
    bool? adminDesigOther,
  }) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      showVerifyBanner: showVerifyBanner ?? this.showVerifyBanner,
      isResetMode: isResetMode ?? this.isResetMode,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      obscurePass: obscurePass ?? this.obscurePass,
      obscureCurrentPassword:
          obscureCurrentPassword ?? this.obscureCurrentPassword,
      showStaffOptions: showStaffOptions ?? this.showStaffOptions,
      activeDialog: activeDialog ?? this.activeDialog,
      activeSnackbar: activeSnackbar ?? this.activeSnackbar,
      snackbarMessage: clearSnackbarMessage
          ? null
          : snackbarMessage ?? this.snackbarMessage,
      currentStep: currentStep ?? this.currentStep,
      selectedRole: selectedRole ?? this.selectedRole,
      childDob: clearChildDob ? null : childDob ?? this.childDob,
      childGender: childGender ?? this.childGender,
      relation: relation ?? this.relation,
      relationOther: relationOther ?? this.relationOther,
      teacherDesig: teacherDesig ?? this.teacherDesig,
      teacherDesigOther: teacherDesigOther ?? this.teacherDesigOther,
      adminDesig: adminDesig ?? this.adminDesig,
      adminDesigOther: adminDesigOther ?? this.adminDesigOther,
    );
  }
}

class AuthController extends StateNotifier<AuthFormState> {
  AuthController() : super(const AuthFormState()) {
    _initPhoneListeners();
    _initDropdownDefaults();
  }

  final _client = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSub;

  final loginFormKey = GlobalKey<FormState>();
  final step1Key = GlobalKey<FormState>();
  final step2Key = GlobalKey<FormState>();
  final step3Key = GlobalKey<FormState>();
  final forgotFormKey = GlobalKey<FormState>();
  final changePassFormKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final currentPasswordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final phoneDigitsCtrl = TextEditingController();
  final referralCtrl = TextEditingController();
  final emergencyNameCtrl = TextEditingController();
  final emergencyPhoneCtrl = TextEditingController();
  final emergencyPhoneDigitsCtrl = TextEditingController();
  final relationCtrl = TextEditingController();
  final childNameCtrl = TextEditingController();
  final allergyCtrl = TextEditingController();
  final medCtrl = TextEditingController();
  final classroomCodeCtrl = TextEditingController();
  final staffIdCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final centerNameCtrl = TextEditingController();
  final adminDesigCtrl = TextEditingController();

  void _initPhoneListeners() {
    phoneDigitsCtrl.addListener(_syncPhone);
    emergencyPhoneDigitsCtrl.addListener(_syncEmergencyPhone);
  }

  void _initDropdownDefaults() {
    relationCtrl.text = state.relation;
    designationCtrl.text = state.teacherDesig;
    adminDesigCtrl.text = state.adminDesig;
  }

  void _syncPhone() => phoneCtrl.text = '+91${phoneDigitsCtrl.text.trim()}';

  void _syncEmergencyPhone() =>
      emergencyPhoneCtrl.text = '+91${emergencyPhoneDigitsCtrl.text.trim()}';

  void prefillPhoneDigits() {
    final existing = phoneCtrl.text;
    if (existing.startsWith('+91')) {
      phoneDigitsCtrl.text = existing.substring(3);
    }
    final existingEmg = emergencyPhoneCtrl.text;
    if (existingEmg.startsWith('+91')) {
      emergencyPhoneDigitsCtrl.text = existingEmg.substring(3);
    }
  }

  void _setLoading(bool v) => state = state.copyWith(isLoading: v);

  void _setDialog(AuthDialog d) => state = state.copyWith(activeDialog: d);

  void _setSnackbar(AuthSnackbar s, {String? message}) =>
      state = state.copyWith(activeSnackbar: s, snackbarMessage: message);

  void clearDialog() => state = state.copyWith(activeDialog: AuthDialog.none);

  void clearSnackbar() => state = state.copyWith(
    activeSnackbar: AuthSnackbar.none,
    clearSnackbarMessage: true,
  );

  void toggleObscurePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleObscureConfirm() =>
      state = state.copyWith(obscureConfirm: !state.obscureConfirm);

  void toggleObscurePass() =>
      state = state.copyWith(obscurePass: !state.obscurePass);

  void toggleObscureCurrentPassword() => state = state.copyWith(
    obscureCurrentPassword: !state.obscureCurrentPassword,
  );

  void dismissVerifyBanner() => state = state.copyWith(showVerifyBanner: false);

  void setResetMode(bool v) => state = state.copyWith(isResetMode: v);

  void setRole(String role) => state = state.copyWith(selectedRole: role);

  void goToStep(int step) => state = state.copyWith(currentStep: step);

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setChildDob(DateTime dob) => state = state.copyWith(childDob: dob);

  void setChildGender(String gender) =>
      state = state.copyWith(childGender: gender);

  void toggleStaffOptions() =>
      state = state.copyWith(showStaffOptions: !state.showStaffOptions);

  void setRelation(String v) {
    final isOther = v == 'other';
    if (!isOther) relationCtrl.text = v;
    state = state.copyWith(relation: v, relationOther: isOther);
  }

  void setTeacherDesig(String v) {
    final isOther = v == 'other';
    if (!isOther) designationCtrl.text = v;
    state = state.copyWith(teacherDesig: v, teacherDesigOther: isOther);
  }

  void setAdminDesig(String v) {
    final isOther = v == 'other';
    if (!isOther) adminDesigCtrl.text = v;
    state = state.copyWith(adminDesig: v, adminDesigOther: isOther);
  }

  void listenToAuthState({
    required void Function(String route) onAuthenticated,
  }) {
    _authSub?.cancel();
    _authSub = _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        setResetMode(true);
        return;
      }

      if ((event == AuthChangeEvent.signedIn ||
              event == AuthChangeEvent.tokenRefreshed) &&
          session != null) {
        state = state.copyWith(showVerifyBanner: false);
        final role = session.user.userMetadata?['role'] as String? ?? 'parent';
        onAuthenticated(routeForRole(role));
      }
    });
  }

  void cancelAuthListener() {
    _authSub?.cancel();
    _authSub = null;
  }

  // ── Sign In ─────────────────────────────────────────────────────────────
  // After credentials are verified, parents get an extra approval check.
  // If approval_status != 'approved', sign them out and redirect to
  // /pending-approval so they see a friendly waiting screen.
  Future<void> signIn({required void Function(String route) onSuccess}) async {
    if (!loginFormKey.currentState!.validate()) return;
    state = state.copyWith(isLoading: true, showVerifyBanner: false);

    try {
      final response = await _client.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = response.user;
      final role = user?.userMetadata?['role'] as String? ?? 'parent';

      // Approval gate — only parents need it
      if (role == 'parent') {
        final parentRow = await _client
            .from('parents')
            .select('approval_status')
            .eq('id', user!.id)
            .maybeSingle();

        final approvalStatus =
            parentRow?['approval_status'] as String? ?? 'pending';

        if (approvalStatus != 'approved') {
          // Sign them out so the auth session doesn't linger
          await _client.auth.signOut();
          // Redirect to the pending screen
          onSuccess('/pending-approval');
          return;
        }
      }

      onSuccess(routeForRole(role));
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      final code = (e.code ?? '').toLowerCase();

      if (msg.contains('email not confirmed') ||
          code == 'email_not_confirmed') {
        state = state.copyWith(showVerifyBanner: true);
      } else if (msg.contains('banned') ||
          msg.contains('disabled') ||
          code == 'user_banned') {
        _setSnackbar(
          AuthSnackbar.banned,
          message:
              'Your account has been blocked. Please contact the center admin.',
        );
      } else {
        debugPrint('[Auth] SignIn failed: ${e.message} | code: ${e.code}');
        _setDialog(AuthDialog.credentialError);
      }
    } catch (e, stack) {
      debugPrint('[Auth] SignIn unexpected error: $e\n$stack');
      _setSnackbar(
        AuthSnackbar.networkError,
        message: 'Connection error. Check your internet and try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign Up ──────────────────────────────────────────────────────────────
  // Parents are created with approval_status = 'pending' in user metadata.
  // The Supabase trigger (or edge function) should copy this to the parents
  // table. If there's no trigger, the admin_users_controller handles it.
  Future<void> signUp({required VoidCallback onSuccess}) async {
    _setLoading(true);

    try {
      final user = UserModel(
        id: '',
        fullName: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        role: state.selectedRole,
        referralCode: referralCtrl.text.trim(),
        emergencyContactName: emergencyNameCtrl.text.trim(),
        emergencyContactPhone: emergencyPhoneCtrl.text.trim(),
        relationship: relationCtrl.text.trim(),
        staffId: staffIdCtrl.text.trim(),
        designation: designationCtrl.text.trim().isEmpty
            ? (state.selectedRole == 'teacher' ? 'Teacher' : 'Center Director')
            : designationCtrl.text.trim(),
        centerName: centerNameCtrl.text.trim(),
      );

      ChildModel? child;
      if (state.selectedRole == 'parent' && state.childDob != null) {
        child = ChildModel(
          name: childNameCtrl.text.trim(),
          dob: state.childDob!.toIso8601String().split('T').first,
          gender: state.childGender,
          allergies: allergyCtrl.text.trim(),
          medicalNotes: medCtrl.text.trim(),
          classroomCode: classroomCodeCtrl.text.trim(),
        );
      }

      final meta = user.toMetadata();
      if (child != null) meta.addAll(child.toMetadata());

      // Tag parent signups so the DB trigger sets approval_status = 'pending'
      if (state.selectedRole == 'parent') {
        meta['approval_status'] = 'pending';
      }

      if (state.selectedRole == 'admin') {
        _setSnackbar(
          AuthSnackbar.genericError,
          message: 'Admin accounts must be created from the admin dashboard.',
        );
        _setLoading(false);
        return;
      }

      Map<String, dynamic>? referral;
      if (state.selectedRole != 'parent') {
        final referralCode = referralCtrl.text.trim();
        if (referralCode.isEmpty) {
          _setSnackbar(
            AuthSnackbar.genericError,
            message: 'Please enter a valid referral code.',
          );
          _setLoading(false);
          return;
        }

        referral = await _client
            .from('referral_codes')
            .select()
            .eq('code', referralCode)
            .eq('role', state.selectedRole)
            .eq('is_used', false)
            .eq('is_active', true)
            .maybeSingle();

        if (referral == null) {
          _setSnackbar(
            AuthSnackbar.genericError,
            message: 'Invalid referral code.',
          );
          _setLoading(false);
          return;
        }

        final expiresAt = referral['expires_at'];
        if (expiresAt != null) {
          final expiryDate = DateTime.tryParse(expiresAt.toString());
          if (expiryDate != null &&
              expiryDate.isBefore(DateTime.now().toUtc())) {
            _setSnackbar(
              AuthSnackbar.genericError,
              message: 'Referral code expired.',
            );
            _setLoading(false);
            return;
          }
        }
      }

      final response = await _client.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        data: meta,
      );

      if (state.selectedRole != 'parent' && referral != null) {
        final userId = response.user?.id;
        if (userId != null) {
          await _client
              .from('referral_codes')
              .update({
                'is_used': true,
                'used_by': userId,
                'used_at': DateTime.now().toUtc().toIso8601String(),
              })
              .eq('id', referral['id']);
        }
      }
      if (state.selectedRole == 'parent') {
        await _client.from('notifications').insert({
          'title': 'New Parent Registration',
          'message':
              '${nameCtrl.text.trim()} has registered and is awaiting approval.',
          'type': 'parent_signup',
          'target_role': 'admin',
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'is_read': false,
        });
      }

      onSuccess();
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('user already registered') ||
          msg.contains('email already in use') ||
          msg.contains('already been registered')) {
        _setDialog(AuthDialog.emailInUse);
      } else {
        _setSnackbar(
          AuthSnackbar.genericError,
          message: 'Signup failed: ${e.message}',
        );
      }
    } on PostgrestException catch (e) {
      debugPrint('[Auth] Signup referral update failed: ${e.message}');
      _setSnackbar(
        AuthSnackbar.genericError,
        message:
            'Signup succeeded, but the referral could not be recorded. Please contact support.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    final parentResult = await _client
        .from('parents')
        .select('id')
        .eq('email', email)
        .maybeSingle();
    final teacherResult = await _client
        .from('teachers')
        .select('id')
        .eq('email', email)
        .maybeSingle();
    return parentResult != null || teacherResult != null;
  }

  Future<void> sendPasswordResetEmail({required VoidCallback onSuccess}) async {
    if (!forgotFormKey.currentState!.validate()) return;
    _setLoading(true);

    try {
      final email = emailCtrl.text.trim();
      final exists = await isEmailRegistered(email);
      if (!exists) {
        _setSnackbar(
          AuthSnackbar.notRegistered,
          message: 'This email is not registered. Please sign up first.',
        );
        return;
      }
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.tinysteps://login-callback',
      );
      _setDialog(AuthDialog.resetEmailSent);
      onSuccess();
    } on AuthException catch (e) {
      _setSnackbar(AuthSnackbar.genericError, message: e.message);
    } catch (e, stack) {
      debugPrint('[Auth] ResetPassword unexpected error: $e\n$stack');
      _setSnackbar(
        AuthSnackbar.networkError,
        message: 'Connection error. Check your internet and try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePassword({required VoidCallback onSuccess}) async {
    if (!forgotFormKey.currentState!.validate()) return;
    _setLoading(true);

    try {
      await _client.auth.updateUser(
        UserAttributes(password: passCtrl.text.trim()),
      );
      _setDialog(AuthDialog.passwordUpdated);
      onSuccess();
    } on AuthException catch (e) {
      _setSnackbar(AuthSnackbar.genericError, message: e.message);
    } catch (e, stack) {
      debugPrint('[Auth] UpdatePassword unexpected error: $e\n$stack');
      _setSnackbar(
        AuthSnackbar.networkError,
        message: 'Connection error. Check your internet and try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required VoidCallback onSuccess,
  }) async {
    _setLoading(true);
    try {
      final email = _client.auth.currentUser?.email ?? '';
      await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      _setDialog(AuthDialog.passwordUpdated);
      onSuccess();
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid') || msg.contains('wrong')) {
        _setSnackbar(
          AuthSnackbar.genericError,
          message: 'Current password is incorrect.',
        );
      } else {
        _setSnackbar(AuthSnackbar.genericError, message: e.message);
      }
    } catch (e, stack) {
      debugPrint('[Auth] ChangePassword unexpected error: $e\n$stack');
      _setSnackbar(
        AuthSnackbar.networkError,
        message: 'Connection error. Check your internet and try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: emailCtrl.text.trim(),
      );
      _setSnackbar(AuthSnackbar.resendSuccess);
    } catch (_) {
      _setSnackbar(AuthSnackbar.resendFail);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> pickChildDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: const Color(0xFFFF6B4A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setChildDob(picked);
  }

  String routeForRole(String? role) {
    return switch (role) {
      'teacher' => '/teacher',
      'admin' => '/admin',
      _ => '/parent',
    };
  }

  void resetRegisterState() {
    for (final c in [
      emailCtrl,
      passCtrl,
      confirmCtrl,
      nameCtrl,
      phoneCtrl,
      phoneDigitsCtrl,
      referralCtrl,
      emergencyNameCtrl,
      emergencyPhoneCtrl,
      emergencyPhoneDigitsCtrl,
      relationCtrl,
      childNameCtrl,
      allergyCtrl,
      medCtrl,
      classroomCodeCtrl,
      staffIdCtrl,
      designationCtrl,
      centerNameCtrl,
      adminDesigCtrl,
    ]) {
      c.clear();
    }
    _initDropdownDefaults();
    state = const AuthFormState();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    phoneDigitsCtrl.removeListener(_syncPhone);
    emergencyPhoneDigitsCtrl.removeListener(_syncEmergencyPhone);
    for (final c in [
      emailCtrl,
      passCtrl,
      confirmCtrl,
      currentPasswordCtrl,
      nameCtrl,
      phoneCtrl,
      phoneDigitsCtrl,
      referralCtrl,
      emergencyNameCtrl,
      emergencyPhoneCtrl,
      emergencyPhoneDigitsCtrl,
      relationCtrl,
      childNameCtrl,
      allergyCtrl,
      medCtrl,
      classroomCodeCtrl,
      staffIdCtrl,
      designationCtrl,
      centerNameCtrl,
      adminDesigCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthFormState>(
      (ref) => AuthController(),
    );
